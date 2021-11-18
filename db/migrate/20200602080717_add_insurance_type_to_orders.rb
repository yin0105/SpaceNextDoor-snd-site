# frozen_string_literal: true

class AddInsuranceTypeToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :insurance_type, :string
  end
end
