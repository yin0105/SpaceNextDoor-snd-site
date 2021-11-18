# frozen_string_literal: true

class CreatePaymentMethods < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_methods do |t|
      t.references :user, foreign_key: true
      t.string :type
      t.string :identifier
      t.date :expiried_date
      t.string :token

      t.timestamps
    end
  end
end
