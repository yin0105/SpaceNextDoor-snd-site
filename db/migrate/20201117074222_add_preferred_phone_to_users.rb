# frozen_string_literal: true

class AddPreferredPhoneToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :preferred_phone, :string
  end
end
