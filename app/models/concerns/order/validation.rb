# frozen_string_literal: true

class Order
  module Validation
    extend ActiveSupport::Concern

    included do
      validate :validate_payment_cycle, on: :update
      validate :maximum_damage_fee, if: -> { reviewed? }, on: :update
      validate :discount_needed_days, if: -> { discounted? }, on: %i[create update]
    end

    private

    def validate_payment_cycle
      return if remain_payment_cycle <= total_payment_cycle && remain_payment_cycle >= 0

      errors.add(:remain_payment_cycle, :invalid_payment_cycle)
    end

    def maximum_damage_fee
      return if damage_fee <= deposit

      errors.add(:damage_fee, :excceed_deposit)
    end

    def discount_needed_days
      case discount_code
      when 'one_month'
        if days < Order::DISCOUNT_REQUIRED_DAYS_ONE_MONTH
          errors.add(:discount_code, :not_over_one_month_needed_days)
        end
      when 'two_months'
        if days < Order::DISCOUNT_REQUIRED_DAYS_TWO_MONTHS
          errors.add(:discount_code, :not_over_two_months_needed_days)
        end
      when 'six_months'
        if days < Order::DISCOUNT_REQUIRED_DAYS_SIX_MONTHS
          errors.add(:discount_code, :not_over_six_months_needed_days)
        end
      end
    end
  end
end
