# frozen_string_literal: true

class AddBiographyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :biography, :text
  end
end
