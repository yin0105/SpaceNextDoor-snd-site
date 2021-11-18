# frozen_string_literal: true

class Order < ApplicationRecord
  include Order::Relation
  include Order::Lifecycle
  include Order::Service
  include Order::Validation

  include Notifiable
  include Schedulable

  self.inheritance_column = :_type
  has_paper_trail

  schedule :payment, :charge_user
  schedule :end, :complete!
  schedule :long_lease_end, :cancel_long_lease
  schedule :long_lease_before_end, lambda {
    send_notification(action: :long_lease_will_expired_for_host, resource: self, klass: :order)
  }
  schedule :before_end, lambda {
    send_notification(action: :will_expired_for_host, resource: self, klass: :order)
    send_notification(action: :will_expired_for_guest, resource: self, klass: :order)
  }

  # constants
  TYPE = { payoff: 0, instalment: 1 }.freeze
  STATUS = { pending: 0, active: 1, cancelled: 2, completed: 3, reviewed: 4, early_ended: 5, full_refunded: 6 }.freeze

  LONGEST_YEAR = 2
  INTERVAL = Settings.order.extended_days

  # DISCOUNT_DAYS = (total_months * 30) - 1
  DISCOUNT_ONE_MONTH_DAYS = 89
  DISCOUNT_TWO_MONTHS_DAYS = 179
  DISCOUNT_SIX_MONTHS_DAYS = 179

  # DISCOUNT_REQUIRED_DAYS = total_months * 30
  DISCOUNT_REQUIRED_DAYS_ONE_MONTH = 90
  DISCOUNT_REQUIRED_DAYS_TWO_MONTHS = 180
  DISCOUNT_REQUIRED_DAYS_SIX_MONTHS = 180

  scope :valid, -> { where.not(start_at: nil, end_at: nil) }

  enum type: TYPE
  enum status: STATUS
  enum discount_code: {
    one_month: 1,
    two_months: 2,
    six_months: 3
  }, _suffix: true

  enum rent_payout_type: {
    one_month: 1,
    ten_days: 2
  }, _suffix: true

  enum transform_long_lease_by: {
    transform_long_lease_by_admin: 'admin',
    transform_long_lease_by_guest: 'guest'
  }

  monetize :price_cents, numericality: { greater_than: 0 }
  monetize :damage_fee_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :premium_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :add_fee_cents, numericality: true

  include Order::PublicApi
  include Order::SlotsUpdate
  include Order::HasAASMStatus

  private

  def cancel_long_lease
    OrderEarlyEndService.new(self).start!
  end

  def charge_user
    PaymentJob.set(retry: false).perform_later(self)
  end
end
