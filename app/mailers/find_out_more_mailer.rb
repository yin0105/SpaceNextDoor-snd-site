# frozen_string_literal: true

class FindOutMoreMailer < ApplicationMailer
  def notify(request)
    @request = request
    mail(
      to: Settings.mail.recipient,
      sender: Settings.mailer.default.from,
      subject: 'Space Next Door Storage Enquiry',
      from: request.email,
      &WAYS
    )
  end
end
