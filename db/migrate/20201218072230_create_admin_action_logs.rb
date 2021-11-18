# frozen_string_literal: true

class CreateAdminActionLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_action_logs do |t|
      t.references :admin, foreign_key: true
      t.integer :target_id
      t.string :target_type
      t.integer :target_version_id
      t.string :event
      t.integer :status, default: 0
      t.string :request_id

      t.timestamps
    end
  end
end
