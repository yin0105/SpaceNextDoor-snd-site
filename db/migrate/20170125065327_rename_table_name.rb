# frozen_string_literal: true

class RenameTableName < ActiveRecord::Migration[5.0]
  def change
    rename_table :payment_methods, :user_payment_methods
  end
end
