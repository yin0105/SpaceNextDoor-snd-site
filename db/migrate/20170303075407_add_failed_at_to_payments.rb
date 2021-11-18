# frozen_string_literal: true

class AddFailedAtToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :failed_at, :datetime
    add_index :payments, %i[failed_at status]
  end
end
