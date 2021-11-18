# frozen_string_literal: true

module Accounting
  class RefundConfirmService
    def initialize(payout)
      @payment = payout.payment
      @guest_payout = payout.user.as_guest.pending_account
      @guest = payout.user.as_guest.account
    end

    def lock_accounts
      [@guest_payout, @guest]
    end

    def start
      payout_refund
    end

    private

    def payout_refund
      DoubleEntry.transfer(
        @payment.refund,
        from: @guest_payout,
        to: @guest,
        code: Accounting::CODE[:payout_refund]
      )
    end
  end
end
