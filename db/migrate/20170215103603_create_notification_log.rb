# frozen_string_literal: true

class CreateNotificationLog < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_logs do |t|
      t.references :user, foreign_key: true
      t.references :notification, foreign_key: true
      t.timestamps
    end
  end
end
