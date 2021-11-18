# frozen_string_literal: true

class PaymentJob < ApplicationJob
  queue_as :payment

  rescue_from(Stripe::InvalidRequestError) { to_retry }
  rescue_from(VerifyPaymentService::NoRemainPaymentError) {}
  rescue_from(VerifyPaymentService::OrderStatusError) {}
  rescue_from(ChargeService::CardError) do |e|
    to_retry e.message
    notify_card_error
  end

  def perform(order)
    CreatePaymentService.new(order).start!
  end

  private

  def to_retry(message)
    @payment = InitializePaymentService.new(arguments.first).start!
    @payment.error_message = @payment.error_message.to_s + message
    @payment.retry!
    RetryPaymentJob.set(wait: 1.day).perform_later(@payment)
  end

  def notify_card_error
    @payment.notify_card_error
  end
end
