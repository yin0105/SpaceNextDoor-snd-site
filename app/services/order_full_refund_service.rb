# frozen_string_literal: true

class OrderFullRefundService
  class PaymentUncompletedError < RuntimeError; end
  class NotFullRefundableError < RuntimeError; end

  def initialize(order)
    @order = order
  end

  def start!
    raise NotFullRefundableError unless @order.full_refundable_by_admin?
    raise PaymentUncompletedError unless @order.last_payment_completed?

    DoubleEntry.lock_accounts(*Accounting::OrderFullRefundService.new(@order).lock_accounts) do
      @order.assign_attributes(long_term_cancelled_at: Time.zone.now) if @order.long_term?

      @order.full_refunded!
      OrderFullCancelScheduleService.new(@order).start!
    end
  end
end
