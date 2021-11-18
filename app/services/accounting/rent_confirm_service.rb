# frozen_string_literal: true

module Accounting
  class RentConfirmService
    def initialize(payout)
      @payment = payout.payment
      @host_payout = payout.user.as_host.pending_account
      @host = payout.user.as_host.account
    end

    def lock_accounts
      [@host_payout, @host]
    end

    def start
      payout_rent
    end

    private

    def payout_rent
      DoubleEntry.transfer(
        @payment.host_rent,
        from: @host_payout,
        to: @host,
        code: Accounting::CODE[:payout_rent]
      )
    end
  end
end
