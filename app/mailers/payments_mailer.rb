# frozen_string_literal: true

class PaymentsMailer < ApplicationMailer
  helper %i[spaces view]

  def receipt(payment)
    @payment = payment
    @order = payment.order
    @user = payment.user
    subject = 'Your Booking with Space Next Door'
    subject += ' (Renewal)' unless @payment.serial == 1

    if @order.insurance_enable?
      attachments['Insurance Terms and Conditions.pdf'] = File.read(Rails.root.join('public/insurance_terms.pdf'))
    end
    mail(to: @user.email,
         bcc: Settings.notification.bcc_list,
         subject: subject, &WAYS)
  end

  def card_error(payment)
    @payment = payment
    @order = payment.order
    @user = payment.user

    mail(to: @user.email,
         bcc: Settings.notification.bcc_list,
         subject: "Payment declined for Transaction No. #{@payment.identity}", &WAYS)
  end
end
