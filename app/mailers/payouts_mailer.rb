# frozen_string_literal: true

class PayoutsMailer < ApplicationMailer
  helper :mailer

  def rent(payout)
    @payout = payout
    @user = payout.user
    @order = payout.order
    @space = payout.space

    mail(to: @payout.user.email,
         bcc: Settings.notification.bcc_list,
         subject: "Space Next Door Payout for Transaction No. #{@payout.payment_identity}", &WAYS)
  end

  def deposit(payout)
    @payout = payout
    @order = payout.payment.order
    @user = payout.user
    mail(to: @payout.user.email,
         bcc: Settings.notification.bcc_list,
         subject: "Space Next Door Refunds Deposit for Transaction No. #{@payout.payment_identity}", &WAYS)
  end

  def refund(payout)
    @payout = payout
    @order = payout.order
    @user = payout.user
    @space = payout.space
    @payment = payout.payment

    mail(to: @payout.user.email,
         bcc: Settings.notification.bcc_list,
         subject: "Space Next Door Refunds Storage Fees for Transaction No. #{@payout.payment_identity}", &WAYS)
  end
end
