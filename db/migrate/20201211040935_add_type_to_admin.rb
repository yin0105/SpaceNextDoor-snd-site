# frozen_string_literal: true

class AddTypeToAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :type, :string, default: 'Admin::General'
  end
end
