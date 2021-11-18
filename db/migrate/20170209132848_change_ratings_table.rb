# frozen_string_literal: true

class ChangeRatingsTable < ActiveRecord::Migration[5.0]
  def change
    add_column :ratings, :rater_type, :string
    remove_column :ratings, :completed, :boolean
    add_column :ratings, :status, :integer
  end
end
