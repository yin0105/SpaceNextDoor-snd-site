# frozen_string_literal: true

class RemoveDaysColumnFromOrder < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :days, :integer
  end
end
