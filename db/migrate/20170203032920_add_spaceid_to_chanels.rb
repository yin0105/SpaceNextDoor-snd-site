# frozen_string_literal: true

class AddSpaceidToChanels < ActiveRecord::Migration[5.0]
  def change
    add_column :chanels, :space_id, :integer
    add_index :chanels, :space_id
  end
end
