# frozen_string_literal: true

class AddCurrencyToOrder < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :price, :integer
    add_monetize :orders, :price
  end
end
