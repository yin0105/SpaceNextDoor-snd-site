# frozen_string_literal: true

class ChangeExpiriedDateToExpiryDateInPaymentMethods < ActiveRecord::Migration[5.0]
  def change
    rename_column :payment_methods, :expiried_date, :expiry_date
  end
end
