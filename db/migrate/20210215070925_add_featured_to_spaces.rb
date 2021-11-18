# frozen_string_literal: true

class AddFeaturedToSpaces < ActiveRecord::Migration[5.2]
  def change
    add_column :spaces, :featured, :boolean, default: false
  end
end
