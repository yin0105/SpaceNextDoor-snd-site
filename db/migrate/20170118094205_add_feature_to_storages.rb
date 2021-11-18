# frozen_string_literal: true

class AddFeatureToStorages < ActiveRecord::Migration[5.0]
  def change
    add_column :storages, :feature, :integer, default: [], array: true
    add_column :storages, :facility, :integer, default: [], array: true
    add_column :storages, :rules, :integer, default: [], array: true
    add_column :storages, :other_rules, :string
  end
end
