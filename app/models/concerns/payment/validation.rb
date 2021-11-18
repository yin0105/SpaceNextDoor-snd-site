# frozen_string_literal: true

class Payment
  module Validation
    extend ActiveSupport::Concern

    included do
      validates :payment_type, :identifier, :service_start_at, :service_end_at, presence: true
      validate :validate_service_start
      validate :validate_service_end
      validate :validate_rent_amount, if: -> { order.discounted? }
      validate :validate_host_service_fee_amount, if: -> { order.discounted? }
      validate :validate_guest_service_fee_amount, if: -> { order.discounted? }
      validates :rent_cents, :guest_service_fee_cents, :host_service_fee_cents, unless: -> { order.discounted? }, numericality: { greater_than_or_equal_to: 0 }
    end

    private

    def validate_service_start
      return if errors.any?
      return if service_start_at >= order.start_at.beginning_of_day

      errors.add(:service_start_at, :invalid_service_start_time)
    end

    def validate_service_end
      return if errors.any?
      return if service_end_at <= order.end_at.end_of_day

      errors.add(:service_end_at, :invalid_service_end_time)
    end

    def validate_rent_amount
      return unless rent_cents.negative?

      errors.add(:rent_cents, :invalid_rent_amount)
    end

    def validate_host_service_fee_amount
      return unless host_service_fee_cents.negative?

      errors.add(:host_service_fee_cents, :invalid_host_service_fee_amount)
    end

    def validate_guest_service_fee_amount
      return unless guest_service_fee_cents.negative?

      errors.add(:guest_service_fee_cents, :invalid_guest_service_fee_amount)
    end
  end
end
