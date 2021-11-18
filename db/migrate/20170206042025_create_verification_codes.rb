# frozen_string_literal: true

class CreateVerificationCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :verification_codes do |t|
      t.references :user, foreign_key: true
      t.integer :type
      t.string :code
      t.datetime :expiry_at

      t.timestamps
    end

    add_index :verification_codes, %i[type code]
    add_index :verification_codes, :expiry_at
  end
end
