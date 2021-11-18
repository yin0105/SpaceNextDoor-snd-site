# frozen_string_literal: true

class AddIsSystemToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :is_system, :boolean, default: false
  end
end
