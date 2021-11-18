# frozen_string_literal: true

class RemoveSpaceidColumnFromChanel < ActiveRecord::Migration[5.0]
  def change
    remove_index :chanels, :host_id
    remove_column :chanels, :host_id, :integer
  end
end
