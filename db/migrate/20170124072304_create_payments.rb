# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.references :order, foreign_key: true
      t.monetize :amount
      t.integer :payment_type, null: false
      t.string :payment_id
      t.integer :type, default: 0
      t.references :user, foreign_key: true
      t.integer :status, default: 0
      t.date :service_start_at, null: false
      t.date :service_end_at, null: false
      t.integer :serial, default: 1

      t.timestamps
    end
  end
end
