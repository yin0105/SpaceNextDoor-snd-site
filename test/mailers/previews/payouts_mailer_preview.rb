# frozen_string_literal: true

class PayoutsMailerPreview < ActionMailer::Preview
  def rent
    PayoutsMailer.rent(Payout.where(type: 'rent').first)
  end

  def deposit
    PayoutsMailer.deposit(Payout.where(type: 'deposit').first)
  end

  def refund
    PayoutsMailer.refund(Payout.where(type: 'refund').first)
  end
end
