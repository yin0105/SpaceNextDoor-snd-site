# frozen_string_literal: true

require 'stripe'

class ChargeService
  class CardError < RuntimeError; end

  def initialize(payment)
    @payment = payment
    @order = payment.order
  end

  def start!
    return nil if @payment.amount.zero?

    # TODO: Implement more payment method to supply different charge method
    response = Stripe::Charge.create(
      amount: @payment.amount.cents,
      currency: @payment.amount.currency,
      customer: @payment.user.payment_method.token,
      capture: true,
      description: "Payment #{@payment.identity} for order ##{@order.id}"
    )
    response['id']
  rescue Stripe::CardError => e
    handle_stripe_error e
  end

  private

  def handle_stripe_error(exception)
    err = extract_error(exception)
    raise CardError, get_message(err)
  end

  def get_message(err)
    message = "\n[Charge failed] #{Time.zone.now.strftime('%FT%T%:z')}"
    if err.present?
      message += "\n Code: #{err[:code]}" if err[:code]
      message += ", Decline code: #{err[:decline_code]}" if err[:decline_code]
      message += ", Message: #{err[:message]}" if err[:message]
    end
    message
  end

  def extract_error(exception)
    return if exception.json_body.nil?

    body = exception.json_body
    body[:error]
  end
end
