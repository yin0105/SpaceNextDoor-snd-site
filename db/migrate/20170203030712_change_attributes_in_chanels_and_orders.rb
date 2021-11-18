# frozen_string_literal: true

class ChangeAttributesInChanelsAndOrders < ActiveRecord::Migration[5.0]
  def change
    remove_index :order_chanels, :order_id
    remove_column :order_chanels, :order_id, :integer
    rename_table :order_chanels, :chanels
    add_column :orders, :chanel_id, :integer
    add_index :orders, :chanel_id
  end
end
