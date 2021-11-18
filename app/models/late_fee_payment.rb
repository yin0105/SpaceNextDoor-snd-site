# frozen_string_literal: true

class LateFeePayment < Payment
  validates :service_end_at, :service_start_at, presence: true
  validate :validate_order_status
  validate :validate_late_fee_period

  schedule :rent_payout, -> { LateFeeRentPayoutJob.perform_later(self) }

  aasm column: :status, enum: true, no_direct_assignment: true do
    event :succeed, after_commit: %i[notify_after_succeed schedule_rent_payout] do
      transitions from: %i[retry pending], to: :success
    end

    event :resolve, after_commit: %i[notify_after_succeed schedule_rent_payout] do
      transitions from: :failed, to: :resolved
      before { self[:resolved_at] = Time.zone.now }
    end
  end

  def amount
    rent + guest_service_fee + premium
  end

  def days_rented
    (service_end_at.to_date - service_start_at.to_date).to_i + 1
  end

  def valid_period?
    return if service_start_at.blank?
    return if order.last_payment.service_end_at.blank?

    service_start_at > order.last_payment.service_end_at
  end

  private

  def notify_after_succeed
    send_notification(action: :receipt, resource: self)
  end

  def setup_payment
    super
    self.deposit = 0
  end

  def validate_service_start
    true
  end

  def validate_service_end
    true
  end

  def validate_order_status
    return if order.finished?

    errors.add(:order_status_error, 'Order status error!')
  end

  def validate_late_fee_period
    return if valid_period?

    errors.add(:late_fee_payment_period_error, 'Late fee payment service period error!')
  end
end
