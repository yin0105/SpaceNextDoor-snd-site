# frozen_string_literal: true

class Payout < ApplicationRecord
  include AASM
  include Notifiable
  self.inheritance_column = :_type

  has_paper_trail

  # constants
  STATUS = {
    pending: 0,
    paid: 1
  }.freeze

  TYPE = {
    rent: 0,
    damage: 1,
    deposit: 2,
    refund: 3
  }.freeze

  ALIAS_PAYMENT_ACTIONS = %i[order order_id rent guest_service_fee host_service_fee deposit host_rent].freeze
  ALIAS_ORDER_ACTIONS = %i[space guest host guest_id host_id deposit damage_fee remain_deposit].freeze

  enum status: STATUS
  enum type: TYPE

  # relationship
  belongs_to :user
  belongs_to :payment

  delegate(*ALIAS_PAYMENT_ACTIONS, to: :payment)
  delegate :identity, :amount, :days, :service_start_at, :service_end_at, :days_rented, :period, to: :payment, prefix: true
  delegate(*ALIAS_ORDER_ACTIONS, to: :order)
  delegate :days, to: :order, prefix: true

  # validations
  monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  # validations
  validates :type, presence: true

  include Payout::PublicApi
  scope :service_start_at_filter_gteq_datetime, ->(date) { joins(:payment).where('payments.service_start_at > ?', Date.parse(date)) }
  scope :service_start_at_filter_lteq_datetime, ->(date) { where('payments.service_start_at < ?', Date.parse(date)) }

  aasm column: :status, enum: true, no_direct_assignment: true do
    state :pending, initial: true
    state :paid

    event :pay, after_commit: :notify_after_pay do
      transitions from: :pending, to: :paid
      after { perform_after_pay }
    end
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[service_start_at_filter_gteq_datetime service_start_at_filter_lteq_datetime]
  end

  private

  def perform_after_pay
    service = "accounting/#{type}_confirm_service".camelize.constantize
    service.new(self).start
  end

  def notify_after_pay
    return unless %w[deposit refund].include? type

    send_notification(action: type.to_sym, resource: self)
  end
end
