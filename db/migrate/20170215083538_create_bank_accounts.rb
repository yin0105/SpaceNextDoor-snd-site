# frozen_string_literal: true

class CreateBankAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_accounts do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.string :country, limit: 4, null: false
      t.string :bank_code, limit: 6, null: false
      t.string :account_name, limit: 32, null: false
      t.string :account_number, limit: 64, null: false

      t.timestamps
    end
  end
end
