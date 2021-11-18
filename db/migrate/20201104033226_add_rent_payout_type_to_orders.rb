# frozen_string_literal: true

class AddRentPayoutTypeToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :rent_payout_type, :integer, default: 2
  end
end
