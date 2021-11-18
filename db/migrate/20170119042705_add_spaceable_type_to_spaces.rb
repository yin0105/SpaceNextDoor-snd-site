# frozen_string_literal: true

class AddSpaceableTypeToSpaces < ActiveRecord::Migration[5.0]
  def change
    add_reference :spaces, :spaceable, polymorphic: true, index: true
  end
end
