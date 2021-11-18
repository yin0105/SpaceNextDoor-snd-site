# frozen_string_literal: true

class AddLongTermCancelledAtToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :long_term_cancelled_at, :date
  end
end
