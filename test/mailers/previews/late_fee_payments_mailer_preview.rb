# frozen_string_literal: true

class LateFeePaymentsMailerPreview < ActionMailer::Preview
  def receipt
    LateFeePaymentsMailer.receipt(Payment.first)
  end

  def card_error
    LateFeePaymentsMailer.card_error(Payment.first)
  end
end
