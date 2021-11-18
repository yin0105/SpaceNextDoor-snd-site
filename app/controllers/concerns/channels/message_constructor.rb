# frozen_string_literal: true

module Channels
  module MessageConstructor
    extend ActiveSupport::Concern

    private

    def build_message
      @message ||= message_scope.new
    end

    def set_messages
      # rubocop:disable Rails/SkipsModelValidations
      @channel.messages.sent_to(current_user).unread.update_all(read_at: Time.zone.now)
    end

    def load_messages
      @messages ||= @channel.messages.includes(:user, :images)
    end

    def message_scope
      current_user.messages
    end
  end
end
