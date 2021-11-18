# frozen_string_literal: true

class ChangeOrderColumn < ActiveRecord::Migration[5.0]
  def change
    change_column_default :orders, :status, from: 0, to: nil
  end
end
