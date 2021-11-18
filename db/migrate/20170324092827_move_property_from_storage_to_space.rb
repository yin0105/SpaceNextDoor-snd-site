# frozen_string_literal: true

class MovePropertyFromStorageToSpace < ActiveRecord::Migration[5.0]
  def change
    Space.all.in_batches.each do |spaces|
      spaces.each { |space| space.update(property: space.spaceable&.property) }
    end

    remove_column :storages, :property, :integer
  end
end
