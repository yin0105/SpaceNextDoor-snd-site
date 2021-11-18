# frozen_string_literal: true

class AddCancelledatInOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :cancelled_at, :datetime
  end
end
