# frozen_string_literal: true

class RemoveMinimalRentTimeFromStorages < ActiveRecord::Migration[5.0]
  def change
    change_column_default :storages, :minimal_rent_time, from: 0, to: nil
    remove_column :storages, :minimal_rent_time, :integer
    add_column :spaces, :minimum_rent_days, :integer
  end
end
