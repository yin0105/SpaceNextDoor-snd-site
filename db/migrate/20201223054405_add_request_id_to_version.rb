# frozen_string_literal: true

class AddRequestIdToVersion < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :request_id, :string
  end
end
