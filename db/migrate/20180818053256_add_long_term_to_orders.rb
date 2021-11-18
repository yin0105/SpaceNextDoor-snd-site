# frozen_string_literal: true

class AddLongTermToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :long_term, :boolean, default: false
    add_index :orders, :long_term
  end
end
