# frozen_string_literal: true

class LateFeePaymentsMailer < ApplicationMailer
  helper %i[spaces view]

  def receipt(late_fee_payment)
    @late_fee_payment = late_fee_payment
    @order = late_fee_payment.order
    @user = late_fee_payment.user

    mail(to: @user.email,
         bcc: Settings.notification.bcc_list,
         subject: 'Your Late Fee Payment with Space Next Door', &WAYS)
  end

  def card_error(late_fee_payment)
    @late_fee_payment = late_fee_payment
    @order = late_fee_payment.order
    @user = late_fee_payment.user

    mail(to: @user.email,
         bcc: Settings.notification.bcc_list,
         subject: "Payment declined for Transaction No. #{@late_fee_payment.identity}", &WAYS)
  end
end
