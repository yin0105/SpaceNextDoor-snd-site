# frozen_string_literal: true

class AddStartEndOnPayout < ActiveRecord::Migration[5.0]
  def change
    add_column :payouts, :start_at, :datetime
    add_column :payouts, :end_at, :datetime
  end
end
