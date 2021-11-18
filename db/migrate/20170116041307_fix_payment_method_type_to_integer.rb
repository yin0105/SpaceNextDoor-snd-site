# frozen_string_literal: true

class FixPaymentMethodTypeToInteger < ActiveRecord::Migration[5.0]
  def change
    change_column :payment_methods, :type, 'integer USING CAST(type AS integer)', default: 0
  end
end
