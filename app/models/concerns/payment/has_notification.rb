# frozen_string_literal: true

class Payment
  module HasNotification
    extend ActiveSupport::Concern

    def notify_after_succeed
      send_notification(action: :receipt, resource: self)
    end

    def notify_card_error
      send_notification(action: :card_error, resource: self) if retry_count.odd?
    end
  end
end
