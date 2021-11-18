# frozen_string_literal: true

class AddRentPayoutTypeToSpaces < ActiveRecord::Migration[5.2]
  def change
    add_column :spaces, :rent_payout_type, :integer, default: 2
  end
end
