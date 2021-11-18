# frozen_string_literal: true

class RemoveDatesFromSpaces < ActiveRecord::Migration[5.0]
  def change
    remove_column :spaces, :dates, :date, array: true
  end
end
