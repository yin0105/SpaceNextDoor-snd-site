# frozen_string_literal: true

class ChangeStorageFeatureAndFacilityToPlural < ActiveRecord::Migration[5.0]
  def change
    rename_column :storages, :feature, :features
    rename_column :storages, :facility, :facilities
  end
end
