# frozen_string_literal: true

class Payout
  module PublicApi
    def duration
      return (end_at.to_date - start_at.to_date).to_i + 1 if start_at.present? && end_at.present?

      # old feature: without end_at start_at
      return payment_days_rented if payment.last_long_lease_payment?

      payment_period
    end

    def period_rent
      return unless rent?

      amount / (1 - order.service_fee_host_rate)
    end

    def period_host_service_fee
      return unless rent?

      period_rent - amount
    end
  end
end
