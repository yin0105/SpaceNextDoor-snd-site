# frozen_string_literal: true

class Order
  module Lifecycle
    extend ActiveSupport::Concern

    included do
      before_validation :prepare_order, if: -> { new_record? }
      before_validation :long_lease_checker, if: -> { pending? }
      before_validation :set_long_lease_end_date, if: -> { pending? }
      before_save :setup_order, if: -> { pending? && start_at && end_at }
      before_save :extend_order, if: -> { active? && extendable? }
    end

    def prepare_order
      self.host_id = space&.user_id
      self.price = space&.daily_price
    end

    def long_lease_checker
      self.long_term = true if long_lease?
    end

    def set_long_lease_end_date
      self.end_at = (start_at + INTERVAL * 2 - 1) if long_lease? && !discounted?
    end

    def setup_order
      self.type = days >= INTERVAL ? 'instalment' : 'payoff'
      self.total_payment_cycle = payoff? ? 1 : (days / INTERVAL.to_f).ceil
      self.remain_payment_cycle = total_payment_cycle
      build_service_fee(
        host_rate: Settings.service_fee.host_rate,
        guest_rate: Settings.service_fee.guest_rate
      )
    end

    def extend_order
      self.end_at = end_at + INTERVAL
      self.total_payment_cycle = total_payment_cycle + 1
      self.remain_payment_cycle = remain_payment_cycle + 1
    end

    def extendable?
      long_term && remain_payment_cycle == 1
    end
  end
end
