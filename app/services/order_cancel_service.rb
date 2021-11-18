# frozen_string_literal: true

class OrderCancelService
  class PrecancelError < RuntimeError; end
  class PaymentUncompletedError < RuntimeError; end

  def initialize(order)
    @order = order
  end

  # only when order is cancelled before started, it can proceed
  def start!
    raise PrecancelError unless @order.cancellable_by_admin?
    raise PaymentUncompletedError unless @order.last_payment_completed?

    DoubleEntry.lock_accounts(*Accounting::OrderCancelService.new(@order).lock_accounts) do
      @order.long_term_cancelled_at = Time.zone.now if @order.long_term?
      @order.cancel!
      OrderFullCancelScheduleService.new(@order).start!
    end
  end
end
