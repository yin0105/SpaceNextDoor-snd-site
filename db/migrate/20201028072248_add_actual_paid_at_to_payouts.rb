# frozen_string_literal: true

class AddActualPaidAtToPayouts < ActiveRecord::Migration[5.2]
  def change
    add_column :payouts, :actual_paid_at, :datetime
  end
end
