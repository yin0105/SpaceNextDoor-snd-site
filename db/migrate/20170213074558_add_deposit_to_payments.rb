# frozen_string_literal: true

class AddDepositToPayments < ActiveRecord::Migration[5.0]
  def change
    add_monetize :payments, :deposit
  end
end
