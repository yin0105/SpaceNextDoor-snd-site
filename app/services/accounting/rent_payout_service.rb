# frozen_string_literal: true

module Accounting
  class RentPayoutService
    def initialize(payment)
      @payment = payment
      @payout_account = payment.order.host.pending_account
      @rent = Accounting.account(:rent)
      @ruc = Accounting.account(:ruc)
      @revenue = Accounting.account(:revenue)
    end

    def start!
      DoubleEntry.lock_accounts(@payout_account, @rent, @ruc, @revenue) do
        hold_rent
        receive_host_service_fee
      end
    end

    private

    def hold_rent
      DoubleEntry.transfer(
        @payment.payout_rent,
        from: @rent,
        to: @payout_account,
        code: Accounting::CODE[:hold_rent]
      )
    end

    def receive_host_service_fee
      DoubleEntry.transfer(
        @payment.payout_host_service_fee,
        from: @ruc,
        to: @revenue,
        code: Accounting::CODE[:receive_hsf]
      )
    end
  end
end
