# frozen_string_literal: true

class ChangeReadyetInMessages < ActiveRecord::Migration[5.0]
  def change
    change_column_default :messages, :read_yet, from: false, to: nil
    remove_column :messages, :read_yet, :boolean
    add_column :messages, :read_at, :datetime
  end
end
