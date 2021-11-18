# frozen_string_literal: true

class ChangeSpacesAvailableDateToAvailableDates < ActiveRecord::Migration[5.0]
  def change
    rename_column :spaces, :available_date, :available_dates
    rename_column :spaces, :required_govid, :govid_required
  end
end
