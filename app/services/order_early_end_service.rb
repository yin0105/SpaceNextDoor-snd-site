# frozen_string_literal: true

class OrderEarlyEndService
  class OrderStatusError < RuntimeError; end
  class NotOverDiscountRequiredDaysError < RuntimeError; end
  class ShortTermEarlyEndError < RuntimeError; end
  class PaymentUncompletedError < RuntimeError; end

  def initialize(order)
    @order = order
  end

  def start!
    raise OrderStatusError unless @order.may_early_end?
    raise NotOverDiscountRequiredDaysError unless @order.discounted_endable?
    raise ShortTermEarlyEndError unless @order.long_lease_transformed_endable?
    raise PaymentUncompletedError unless @order.last_payment_completed?

    DoubleEntry.lock_accounts(*Accounting::OrderCancelService.new(@order).lock_accounts) do
      @order.early_end!
    end
  end
end
