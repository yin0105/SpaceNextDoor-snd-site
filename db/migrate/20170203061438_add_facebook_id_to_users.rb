# frozen_string_literal: true

class AddFacebookIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
  end
end
