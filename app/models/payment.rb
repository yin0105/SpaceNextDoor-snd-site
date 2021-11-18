# frozen_string_literal: true

class Payment < ApplicationRecord
  include Schedulable
  include AASM
  include Notifiable
  ALIAS_ORDER_ACTIONS = %i[space guest host guest_id host_id price].freeze

  belongs_to :order
  belongs_to :user
  has_many :payouts

  has_paper_trail

  delegate(*ALIAS_ORDER_ACTIONS, to: :order)
  delegate :days, to: :order, prefix: true

  enum payment_type: User::PaymentMethod::TYPES
  enum status: { pending: 0, success: 1, retry: 2, failed: 3, resolved: 4, aborted: 5 }

  delegate :host, :guest, to: :order, prefix: false
  delegate :days, to: :order, prefix: true

  schedule :service_start, -> { LeaseStartJob.perform_later(self) }
  schedule :service_end, -> { LeaseEndJob.perform_later(self) }
  schedule :rent_payout, -> { RentPayoutJob.perform_later(self) }

  monetize :rent_cents
  monetize :guest_service_fee_cents
  monetize :host_service_fee_cents
  monetize :deposit_cents
  monetize :premium_cents

  default_scope -> { order(serial: :asc, created_at: :desc) }
  scope :failed_by_day, ->(date) { failed.where(failed_at: date.beginning_of_day..date.end_of_day) }
  scope :valid, -> { where(status: %i[success resolved]) }
  scope :last_month, -> { where(updated_at: (Time.current - 1.month)..Time.current) }
  scope :last_year, -> { where(updated_at: (Time.current - 1.year)..Time.current) }

  aasm column: :status, enum: true, no_direct_assignment: true do
    state :pending, initial: true
    state :success, :retry, :failed, :resolved, :aborted

    event :succeed, after_commit: %i[update_order notify_after_succeed schedule_rent_payout] do
      transitions from: %i[retry pending], to: :success
      after(ensure: true) { perform_after_succeed }
    end

    event :retry do
      transitions from: %i[retry pending], to: :retry
      before { self[:retry_count] += 1 }
    end

    event :fail do
      transitions from: :retry, to: :failed
      before { self[:failed_at] = Time.zone.now }
    end

    event :resolve, after_commit: %i[update_order notify_after_succeed schedule_rent_payout] do
      transitions from: :failed, to: :resolved
      before { self[:resolved_at] = Time.zone.now }
      after(ensure: true) { perform_after_succeed }
    end

    event :abort do
      transitions from: :pending, to: :aborted
    end
  end

  include Payment::PublicApi
  include Payment::HasNotification
  include Payment::HasPayout
  include Payment::Validation

  def self.monthly_revenue
    Money.new(valid.last_month.sum('host_service_fee_cents + guest_service_fee_cents'))
  end

  def self.annual_revenue
    Money.new(valid.last_year.sum('host_service_fee_cents + guest_service_fee_cents'))
  end

  private

  def perform_after_succeed
    schedule_next_payment
    start_accounting
  end

  def update_order
    order.remain_payment_cycle -= 1
    if serial == 1
      order.activate!
    else
      order.save!
    end
    schedule_end_notification if order.remain_payment_cycle.zero?
  end

  def schedule_end_notification
    order.becomes(Order).schedule(:before_end, at: order.end_at - Settings.order.days_to_notify_service_end.days)
    order.becomes(Order).schedule(:end, at: order.next_service_end_at)
  end

  def schedule_next_payment
    # When remain_payment_cycle = 1, it means that the moment of running this line is the last of payment cycle.
    # the value of remain_payment_cycle will be then deducted to 0 after running #update_order.
    return if order.remain_payment_cycle <= 1 || last_long_lease_payment?

    next_payment_day = order.next_service_end_at - Settings.order.days_to_next_service_end.days
    order.becomes(Order).schedule(:payment, at: next_payment_day)
  end

  def start_accounting
    Accounting::PaymentService.new(self).start
    schedule(:service_start, at: service_start_at)
  end
end
