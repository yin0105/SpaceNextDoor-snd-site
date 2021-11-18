# frozen_string_literal: true

class AddIdentifierToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :identifier, :string
    add_index :payments, :identifier
  end
end
