# frozen_string_literal: true

class RenameSquareToAreaInSpaces < ActiveRecord::Migration[5.0]
  def change
    rename_column :spaces, :square, :area
  end
end
