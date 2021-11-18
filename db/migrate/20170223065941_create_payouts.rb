# frozen_string_literal: true

class CreatePayouts < ActiveRecord::Migration[5.0]
  def change
    remove_column :payments, :type, :integer
    rename_column :payments, :payment_id, :transaction_id

    create_table :payouts do |t|
      t.references :payment
      t.references :user
      t.integer :status
      t.integer :type
      t.monetize :amount
      t.timestamps
    end
  end
end
