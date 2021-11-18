# frozen_string_literal: true

class AddInsuranceTypeToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :insurance_type, :string
  end
end
