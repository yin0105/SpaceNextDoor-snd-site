# frozen_string_literal: true

module Accounting
  class DamageConfirmService
    def initialize(payout)
      @order = payout.payment.order
      @host_payout = payout.user.as_host.pending_account
      @host = payout.user.as_host.account
    end

    def lock_accounts
      [@host_payout, @host]
    end

    def start
      payout_damage
    end

    private

    def payout_damage
      DoubleEntry.transfer(
        @order.damage_fee,
        from: @host_payout,
        to: @host,
        code: Accounting::CODE[:payout_damage]
      )
    end
  end
end
