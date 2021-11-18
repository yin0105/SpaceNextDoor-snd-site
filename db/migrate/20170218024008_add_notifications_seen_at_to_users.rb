# frozen_string_literal: true

class AddNotificationsSeenAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :notifications_seen_at, :datetime
  end
end
