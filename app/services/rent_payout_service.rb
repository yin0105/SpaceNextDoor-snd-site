# frozen_string_literal: true

class RentPayoutService
  def initialize(payment)
    @payment = payment
    @order = payment.order
  end

  def start!
    return unless @payment.remain_rent_payout?

    Accounting::RentPayoutService.new(@payment).start!
    Payout.create!(
      payment: @payment,
      user: @order.host.as_user,
      type: :rent,
      start_at: @payment.payout_start_at,
      end_at: @payment.payout_end_at,
      amount: calculate_amount
    )
    schedule_next_payout
  end

  def calculate_amount
    return @payment.payout_rent / 2 if @payment.half_price_discount?
    # The 'one month' discount means first month free
    # The 'two months' discount means first and sixth month free
    # The way of choose free discount promotion is create long lease order at beginning, not includes order that short lease transform long lease
    return 0 if @payment.free_rent_and_service_fee?

    @payment.payout_rent
  end

  def schedule_next_payout
    return if @order.one_month_rent_payout_type?
    return unless @payment.remain_rent_payout?

    @payment.becomes(Payment).schedule(:rent_payout, at: @payment.payout_end_at - 1.day)
  end
end
