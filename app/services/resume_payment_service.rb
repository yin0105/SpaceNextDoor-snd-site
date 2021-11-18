# frozen_string_literal: true

class ResumePaymentService
  def initialize(order)
    @order = order
    @payment = order.payments.failed.last
  end

  def start!
    VerifyPaymentService.new(@payment).start!

    DoubleEntry.lock_accounts(*Accounting::PaymentService.new(@payment).lock_accounts) do
      transaction_id = ChargeService.new(@payment).start!
      @payment.transaction_id = transaction_id
      @payment.failed? ? @payment.resolve! : @payment.succeed!
    end
  rescue VerifyPaymentService::CancelledPaymentError
    @payment.abort!
  end
end
