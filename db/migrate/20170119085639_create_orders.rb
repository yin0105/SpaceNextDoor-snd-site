# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :type, null: false, default: 0
      t.integer :total_payment_cycle, null: false, default: 1
      t.integer :remain_payment_cycle, null: false, default: 1
      t.integer :price, null: false
      t.integer :days, null: false, default: 1
      t.references :host, foreign_key: { to_table: :users }
      t.references :guest, foreign_key: { to_table: :users }
      t.references :space, foreign_key: { to_table: :spaces }
      t.integer :status, null: false, default: 0
      t.date :start_at, null: false
      t.date :end_at, null: false
      t.integer :damage_fee, default: 0
      t.text :note

      t.timestamps
    end

    add_index :orders, :type
    add_index :orders, :status
  end
end
