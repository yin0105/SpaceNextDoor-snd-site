# frozen_string_literal: true

class AddCurrencyToSpaces < ActiveRecord::Migration[5.0]
  def change
    remove_column :spaces, :daily_price, :integer
    add_monetize :spaces, :daily_price
  end
end
