# frozen_string_literal: true

class CreateStorages < ActiveRecord::Migration[5.0]
  def change
    create_table :storages do |t|
      t.references :space, foreign_key: true
      t.integer :checkin_time, default: 0
      t.integer :property, default: 0
      t.integer :category, default: 0
      t.integer :minimal_rent_time, default: 0

      t.timestamps
    end
  end
end
