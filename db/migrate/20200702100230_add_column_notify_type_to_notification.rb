# frozen_string_literal: true

class AddColumnNotifyTypeToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :notify_type, :integer, default: 0
  end
end
