# frozen_string_literal: true

class AddBankInfoToBankAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_accounts, :bank_name, :string, limit: 50
    add_column :bank_accounts, :branch_code, :string, limit: 6
  end
end
