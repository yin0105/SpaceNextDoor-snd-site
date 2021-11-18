# frozen_string_literal: true

class AddInsuranceLockToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :insurance_lock, :boolean, default: false
  end
end
