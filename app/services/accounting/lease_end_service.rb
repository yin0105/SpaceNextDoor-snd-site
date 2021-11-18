# frozen_string_literal: true

module Accounting
  class LeaseEndService
    def initialize(payment)
      @payment = payment
      @payout = @payment.order.host.pending_account
      @rent = Accounting.account(:rent)
      @ruc = Accounting.account(:ruc)
      @revenue = Accounting.account(:revenue)
    end

    def start
      DoubleEntry.lock_accounts(@payout, @rent, @ruc, @revenue) do
        hold_rent
        receive_host_service_fee
      end
    end

    private

    def hold_rent
      DoubleEntry.transfer(
        @payment.host_rent,
        from: @rent,
        to: @payout,
        code: Accounting::CODE[:hold_rent]
      )
    end

    def receive_host_service_fee
      DoubleEntry.transfer(
        @payment.host_service_fee,
        from: @ruc,
        to: @revenue,
        code: Accounting::CODE[:receive_hsf]
      )
    end
  end
end
