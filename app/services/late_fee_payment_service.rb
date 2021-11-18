# frozen_string_literal: true

require 'stripe'

class LateFeePaymentService
  class InvalidPaymentMethodError < RuntimeError; end
  class PaymentFailedError < RuntimeError; end
  class NoRemainPaymentError < RuntimeError; end
  class OrderStatusError < RuntimeError; end
  class CardError < RuntimeError; end

  def initialize(late_fee_payment)
    @order = late_fee_payment.order.becomes(Order)
    @late_fee_payment = late_fee_payment

    setup
  end

  def setup
    @late_fee_payment.valid?
    @late_fee_payment
  end

  def start!
    DoubleEntry.lock_accounts(*Accounting::LateFeePaymentService.new(@late_fee_payment).lock_accounts) do
      charge!
      start_accounting
    end
  rescue Stripe::CardError => e
    handle_stripe_error e
  end

  private

  def charge!
    response = Stripe::Charge.create(
      amount: @late_fee_payment.amount.cents,
      currency: @late_fee_payment.amount.currency,
      customer: @late_fee_payment.user.payment_method.token,
      capture: true,
      description: "Payment #{@late_fee_payment.identifier} for order ##{@order.id}"
    )
    @late_fee_payment.transaction_id = response['id']
    @late_fee_payment.failed? ? @late_fee_payment.resolve! : @late_fee_payment.succeed!
  end

  def start_accounting
    Accounting::LateFeePaymentService.new(@late_fee_payment).start
  end

  def resolve!
    late_fee_payment = @order.late_fees.failed.last
    late_fee_payment.resolve! if late_fee.present?
  end

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
