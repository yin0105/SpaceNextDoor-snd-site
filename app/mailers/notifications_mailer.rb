# frozen_string_literal: true

class NotificationsMailer < ApplicationMailer
  def notification(message, user)
    @title = message.title
    @content = message.content

    mail(to: user.email,
         subject: @title, &WAYS)
  end
end
