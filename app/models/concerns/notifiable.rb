# frozen_string_literal: true

module Notifiable
  extend ActiveSupport::Concern

  def send_notification(action:, resource:, klass: nil)
    mailer = "#{(klass.to_s.presence || self.class.name).pluralize}_mailer".camelize.constantize
    mailer.send(action, resource).deliver_later(wait: 1.minute)
  end
end
