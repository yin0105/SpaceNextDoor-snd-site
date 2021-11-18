# frozen_string_literal: true

class Payment
  module PublicApi
    extend ActiveSupport::Concern

    included do
      alias_method :days, :period
      delegate :last_long_lease_payment?, to: :order
    end

    class_methods do
      def identity_regex
        /(\d{4,})([0]{1})(\d{4,})-(\d+)/
      end

      def ransackable_scopes(_auth_object = nil)
        %i[search_identity_eq]
      end

      def search_identity_eq(value)
        order_id = value.slice(identity_regex, 3)&.to_i
        serial_id = value.slice(identity_regex, 4)&.to_i
        where(order_id: order_id).where(serial: serial_id)
      end
    end

    def amount
      rent + guest_service_fee + deposit + premium
    end

    def host_rent
      return early_end_host_rent if refund_due?

      rent - host_service_fee
    end

    def refund
      OrderRefundFeeService.new(self).start
    end

    def pre_cancel?
      return false unless order.cancelled_at.present? || order.long_term_cancelled_at.present?

      (order.long_term_cancelled_at || order.cancelled_at) < service_start_at
    end

    def refund_due?
      order.long_term_cancelled_at.present? && order.long_term_cancelled_at.to_date < service_end_at.to_date
    end

    def long_term_early_end?
      refund_due? && !pre_cancel?
    end

    def identity
      order.identity + "-#{serial}"
    end

    def period
      ((service_end_at - service_start_at) / 86_400).ceil
    end

    def days_rented
      end_time = [order.long_term_cancelled_at || service_end_at, service_end_at].min

      return 0 if end_time < service_start_at.to_date

      (end_time.to_date - service_start_at.to_date).to_i + 1
    end

    def days_rented_fee
      order.price * days_rented
    end

    def service_fee_to_refund
      order.price * (Order::INTERVAL - days_rented) * order.service_fee_guest_rate
    end

    def early_end_host_service_fee
      days_rented_fee * order.service_fee_host_rate
    end

    def early_end_guest_service_fee
      days_rented_fee * order.service_fee_guest_rate
    end

    def full_refund_guest_service_fee
      0
    end

    def early_end_host_rent
      days_rented_fee - early_end_host_service_fee
    end

    def insurance_enable?
      (insurance_type.present? && insurance_type != Insurance::NULL_INSURANCE_TYPE)
    end

    def free_rent_and_service_fee?
      (order.one_month_discount_code? && serial == 1) ||
        (order.two_months_discount_code? && (serial == 1 || serial == 6))
    end

    def half_price_discount?
      order.six_months_discount_code? && serial < 7
    end
  end
end
