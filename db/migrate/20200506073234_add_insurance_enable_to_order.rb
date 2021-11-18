# frozen_string_literal: true

class AddInsuranceEnableToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :insurance_enable, :boolean, default: false
  end
end
