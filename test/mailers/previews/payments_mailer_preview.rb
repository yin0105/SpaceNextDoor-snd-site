# frozen_string_literal: true

class PaymentsMailerPreview < ActionMailer::Preview
  def receipt
    PaymentsMailer.receipt(Payment.first)
  end

  def card_error
    PaymentsMailer.card_error(Payment.first)
  end
end
