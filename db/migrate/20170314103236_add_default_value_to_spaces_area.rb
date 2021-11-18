# frozen_string_literal: true

class AddDefaultValueToSpacesArea < ActiveRecord::Migration[5.0]
  def change
    change_column_default :spaces, :area, from: nil, to: 0
  end
end
