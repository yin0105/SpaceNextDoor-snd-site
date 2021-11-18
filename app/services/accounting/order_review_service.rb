# frozen_string_literal: true

module Accounting
  class OrderReviewService
    def initialize(order)
      @order = order
      @host_payout = order.host.pending_account
      @guest_payout = order.guest.pending_account
      @deposit = Accounting.account(:deposit)
    end

    def lock_accounts
      [@host_payout, @guest_payout, @deposit]
    end

    def start
      hold_damage_to_host
      hold_deposit_to_guest
    end

    private

    def hold_damage_to_host
      DoubleEntry.transfer(
        @order.damage_fee,
        from: @deposit,
        to: @host_payout,
        code: Accounting::CODE[:hold_damage]
      )
    end

    def hold_deposit_to_guest
      DoubleEntry.transfer(
        @order.remain_deposit,
        from: @deposit,
        to: @guest_payout,
        code: Accounting::CODE[:hold_deposit]
      )
    end
  end
end
