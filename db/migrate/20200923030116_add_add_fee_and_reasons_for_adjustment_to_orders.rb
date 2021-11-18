# frozen_string_literal: true

class AddAddFeeAndReasonsForAdjustmentToOrders < ActiveRecord::Migration[5.2]
  def change
    add_monetize :orders, :add_fee
    add_column :orders, :reasons_for_adjustment, :text
  end
end
