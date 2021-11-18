# frozen_string_literal: true

class ChangeOrdersColumn < ActiveRecord::Migration[5.0]
  def up
    change_column :orders, :start_at, :date, null: true
    change_column :orders, :end_at, :date, null: true
    change_column :orders, :days, :integer, null: true
    change_column_default :orders, :days, nil
  end

  def down
    change_column :orders, :start_at, :date, null: false
    change_column :orders, :end_at, :date, null: false
    change_column :orders, :days, :integer, null: false
    change_column_default :orders, :days, 1
  end
end
