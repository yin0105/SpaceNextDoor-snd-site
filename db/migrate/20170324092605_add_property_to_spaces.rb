# frozen_string_literal: true

class AddPropertyToSpaces < ActiveRecord::Migration[5.0]
  def change
    add_column :spaces, :property, :int
    add_index :spaces, :property
  end
end
