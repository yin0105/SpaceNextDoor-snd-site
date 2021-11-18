# frozen_string_literal: true

class AddLongTermStartAtToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :long_term_start_at, :date
  end
end
