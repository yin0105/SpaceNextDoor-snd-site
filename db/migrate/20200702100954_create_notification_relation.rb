# frozen_string_literal: true

class CreateNotificationRelation < ActiveRecord::Migration[5.2]
  def change
    create_table :user_notification_relations do |t|
      t.belongs_to :user, index: true
      t.belongs_to :notification, index: true
    end
  end
end
