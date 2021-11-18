# frozen_string_literal: true

class AddColumnDiscountCodeToSpace < ActiveRecord::Migration[5.0]
  def change
    add_column :spaces, :discount_code, :integer
  end
end
