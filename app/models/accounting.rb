# frozen_string_literal: true

module Accounting
  CODE = {
    pay: :pay,
    charge: :charge,
    receive_gsf: :receive_guest_service_fee,
    receive_hsf: :receive_host_service_fee,
    collect_deposit: :collect_deposit,
    collect_rent: :collect_rent,
    collect_hsf: :collect_host_service_fee,
    hold_rent: :hold_rent,
    hold_damage: :hold_damage,
    hold_deposit: :hold_deposit,
    hold_refund: :hold_refund,
    payout_rent: :payout_rent,
    payout_damage: :payout_damage,
    payout_deposit: :payout_deposit,
    payout_refund: :payout_refund
  }.freeze

  ACCOUNT = {
    host: :host,
    guest: :guest,
    tc1: :temporary_credit_1,
    tc2: :temporary_credit_2,
    revenue: :revenue,
    deposit: :deposit,
    rent: :rent,
    ruc: :receipt_under_custody,
    host_payout: :host_payout,
    guest_payout: :guest_payout
  }.freeze

  def self.account(key, scope = nil)
    DoubleEntry.account(ACCOUNT[key], scope: scope)
  end
end
