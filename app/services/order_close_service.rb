# frozen_string_literal: true

class OrderCloseService
  def initialize(order, action)
    @order = order
    @action = action
  end

  def execute
    case @action
    when :review then review
    when :cancel then cancel
    when :early_end then cancel
    when :full_refund then full_refund
    end
  end

  def review
    Accounting::OrderReviewService.new(@order).start
    Payout.create!(payment: @order.last_payment.as_payment, user: @order.host.as_user, type: :damage, amount: @order.damage_fee)
    Payout.create!(payment: @order.last_payment.as_payment, user: @order.guest.as_user, type: :deposit, amount: @order.remain_deposit)
  end

  def cancel
    Accounting::OrderCancelService.new(@order).start
    Payout.create!(payment: @order.last_payment.as_payment, user: @order.guest.as_user, type: :refund, amount: @order.last_payment.refund)
  end

  def full_refund
    Accounting::OrderFullRefundService.new(@order).start
    Payout.create!(payment: @order.last_payment.as_payment, user: @order.guest.as_user, type: :refund, amount: @order.last_payment.amount)
  end
end
