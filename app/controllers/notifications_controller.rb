# frozen_string_literal: true

class NotificationsController < ApplicationController
  skip_authorization_check

  def index
    load_notifications
    set_notifications_seen_at
  end

  private

  def set_notifications_seen_at
    current_user.update(notifications_seen_at: Time.zone.now) if current_user.unread_notification?
  end

  def load_notifications
    @notifications ||= Notification.where(notify_type: 0).or(
      Notification.where(id: current_user.notifications.ids)
    )
                                   .order(id: :desc).page(params[:page])
  end
end
