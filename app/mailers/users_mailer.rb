# frozen_string_literal: true

class UsersMailer < Devise::Mailer
  include MailerHelper
  include Devise::Controllers::UrlHelpers
  layout 'mailer'
  default from: Settings.mailer.default.from,
          reply_to: Settings.mailer.default.reply_to

  WAYS = proc do |format|
    format.text
    format.mjml
  end

  def confirmation_instructions(record, token, opts = {})
    @token = token
    customed_mail(record, :confirmation_instructions, opts, &WAYS)
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    customed_mail(record, :reset_password_instructions, opts, &WAYS)
  end

  def password_change(record, opts = {})
    customed_mail(record, :password_change, opts, &WAYS)
  end

  def unlock_instructions(record, token, opts = {})
    @token = token
    customed_mail(record, :unlock_instuctions, opts, &WAYS)
  end

  def sign_up_success(record)
    @resource = record

    mail(to: @resource.email,
         subject: 'Thank you for signing up with Space Next Door!',
         bcc: Settings.notification.bcc_list, &WAYS)
  end
end
