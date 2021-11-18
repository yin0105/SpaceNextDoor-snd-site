# frozen_string_literal: true

class AddResolvedAtToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :resolved_at, :datetime
  end
end
