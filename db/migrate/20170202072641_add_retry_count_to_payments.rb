# frozen_string_literal: true

class AddRetryCountToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :retry_count, :integer, default: 0
  end
end
