# frozen_string_literal: true

class RenameSpaceIdToUserIdFromStorages < ActiveRecord::Migration[5.0]
  def change
    remove_column :storages, :space_id, :integer
    add_reference :storages, :user
  end
end
