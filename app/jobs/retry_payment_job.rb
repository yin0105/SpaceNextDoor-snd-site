# frozen_string_literal: true

class RetryPaymentJob < ApplicationJob
  queue_as :payment

  rescue_from(Stripe::InvalidRequestError) { to_retry }
  rescue_from(VerifyPaymentService::NoRemainPaymentError) {}
  rescue_from(VerifyPaymentService::OrderStatusError) {}
  rescue_from(ChargeService::CardError) do |e|
    to_retry e.message
    notify_card_error
  end

  def perform(payment)
    RetryPaymentService.new(payment).start!
  end

  private

  def to_retry(message)
    @payment = arguments.first
    return @payment.fail! if @payment.retry_count >= 7

    @payment.error_message = @payment.error_message.to_s + message
    @payment.retry!
    retry_job wait: 1.day
  end

  def notify_card_error
    @payment.notify_card_error
  end
end
