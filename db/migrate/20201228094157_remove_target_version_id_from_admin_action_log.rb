# frozen_string_literal: true

class RemoveTargetVersionIdFromAdminActionLog < ActiveRecord::Migration[5.2]
  def change
    remove_column :admin_action_logs, :target_version_id, :integer
  end
end
