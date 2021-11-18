# frozen_string_literal: true

class AddEditStatusToStorages < ActiveRecord::Migration[5.0]
  def change
    add_column :storages, :edit_status, :integer
  end
end
