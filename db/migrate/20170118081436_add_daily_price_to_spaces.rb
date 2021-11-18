# frozen_string_literal: true

class AddDailyPriceToSpaces < ActiveRecord::Migration[5.0]
  def change
    add_column :spaces, :daily_price, :integer
  end
end
