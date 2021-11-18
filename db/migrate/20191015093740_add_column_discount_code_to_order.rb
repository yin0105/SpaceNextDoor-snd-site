# frozen_string_literal: true

class AddColumnDiscountCodeToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :discount_code, :integer
  end
end
