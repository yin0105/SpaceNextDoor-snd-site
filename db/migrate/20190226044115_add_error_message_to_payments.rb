# frozen_string_literal: true

class AddErrorMessageToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :error_message, :text
  end
end
