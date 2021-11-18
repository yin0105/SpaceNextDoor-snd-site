# frozen_string_literal: true

class MessageJob < ApplicationJob
  queue_as :message

  def perform(message)
    MessagesMailer.notification(message).deliver_later if message.latest?
  end
end
