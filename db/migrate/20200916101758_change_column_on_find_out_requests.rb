# frozen_string_literal: true

class ChangeColumnOnFindOutRequests < ActiveRecord::Migration[5.2]
  def up
    add_column :find_out_requests, :identity, :integer, default: 0, null: false
    add_column :find_out_requests, :address, :string
    add_column :find_out_requests, :postal_code, :string, limit: 16
    change_column :find_out_requests, :location, :string, null: true
  end

  def down
    remove_column :find_out_requests, :identity
    remove_column :find_out_requests, :address
    remove_column :find_out_requests, :postal_code
    change_column :find_out_requests, :location, :string, null: false
  end
end
