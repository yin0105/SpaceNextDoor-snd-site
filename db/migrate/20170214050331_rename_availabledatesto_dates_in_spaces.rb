# frozen_string_literal: true

class RenameAvailabledatestoDatesInSpaces < ActiveRecord::Migration[5.0]
  def change
    rename_column :spaces, :available_dates, :dates
  end
end
