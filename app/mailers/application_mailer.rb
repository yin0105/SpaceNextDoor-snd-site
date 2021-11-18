# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  default from: Settings.mailer.default.from,
          reply_to: Settings.mailer.default.reply_to

  WAYS = proc do |format|
    format.text
    format.mjml
  end
end
