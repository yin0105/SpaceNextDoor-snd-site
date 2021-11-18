# frozen_string_literal: true

class ChangeRatingColumn < ActiveRecord::Migration[5.0]
  def change
    remove_index :ratings, :message_id
    remove_column :ratings, :message_id, :integer
  end
end
