# frozen_string_literal: true

class MessagesMailer < ApplicationMailer
  def notification(message)
    @message = message
    mail(to: @message.target_user.email,
         subject: 'Space Next Door Messaging', &WAYS)
  end
end
