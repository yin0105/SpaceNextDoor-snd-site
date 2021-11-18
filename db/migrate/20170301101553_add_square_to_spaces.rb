# frozen_string_literal: true

class AddSquareToSpaces < ActiveRecord::Migration[5.0]
  def change
    add_column :spaces, :square, :float
    add_column :spaces, :height, :float
  end
end
