# frozen_string_literal: true

class VerifyPaymentService
  class OrderStatusError < RuntimeError; end
  class NoRemainPaymentError < RuntimeError; end
  class CancelledPaymentError < RuntimeError; end

  def initialize(payment)
    @payment = payment
    @order = payment.order
  end

  def start!
    raise NoRemainPaymentError unless @order.remain_payment_cycle.positive?
    raise CancelledPaymentError if charge_at_cancellation_date?

    return if chargeable_order?

    raise OrderStatusError, I18n.t('snd.errors.order_status_is_wrong')
  end

  private

  def chargeable_order?
    @order.pending? || @order.active?
  end

  def charge_at_cancellation_date?
    @order.long_term_cancelled_at == Time.zone.today
  end
end
