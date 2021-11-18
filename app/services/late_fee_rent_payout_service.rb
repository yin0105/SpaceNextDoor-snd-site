# frozen_string_literal: true

class LateFeeRentPayoutService
  def initialize(late_fee_payment)
    @late_fee_payment = late_fee_payment
    @order = late_fee_payment.order
  end

  def start!
    Accounting::RentPayoutService.new(@late_fee_payment).start!
    Payout.create!(
      payment: @late_fee_payment,
      user: @order.host.as_user,
      type: :rent,
      start_at: @late_fee_payment.payout_start_at,
      end_at: @late_fee_payment.payout_end_at,
      amount: @late_fee_payment.payout_rent
    )
  end
end
