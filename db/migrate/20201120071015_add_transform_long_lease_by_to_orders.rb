# frozen_string_literal: true

class AddTransformLongLeaseByToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :transform_long_lease_by, :string
  end
end
