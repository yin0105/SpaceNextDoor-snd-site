# frozen_string_literal: true

module Accounting
  class OrderFullRefundService
    def initialize(order)
      @order = order
      @temporary_credit2 = Accounting.account(:tc2)
      @guest_payout = order.guest.pending_account
    end

    def lock_accounts
      [@temporary_credit2, @guest_payout]
    end

    def start
      hold_refund
    end

    private

    def hold_refund
      DoubleEntry.transfer(
        @order.last_payment.amount,
        from: @temporary_credit2,
        to: @guest_payout,
        code: Accounting::CODE[:hold_refund]
      )
    end
  end
end
