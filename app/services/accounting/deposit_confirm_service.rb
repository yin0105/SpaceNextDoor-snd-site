# frozen_string_literal: true

module Accounting
  class DepositConfirmService
    def initialize(payout)
      @order = payout.payment.order
      @guest_payout = payout.user.as_guest.pending_account
      @guest = payout.user.as_guest.account
    end

    def lock_accounts
      [@guest_payout, @guest]
    end

    def start
      payout_deposit
    end

    private

    def payout_deposit
      DoubleEntry.transfer(
        @order.remain_deposit,
        from: @guest_payout,
        to: @guest,
        code: Accounting::CODE[:payout_deposit]
      )
    end
  end
end
