# frozen_string_literal: true

class CreateFindOutRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :find_out_requests do |t|
      t.string :name, null: false
      t.string :phone
      t.string :email, null: false
      t.string :location, null: false
      t.datetime :start_at
      t.datetime :end_at
      t.text :description
      t.integer :size, null: false
      t.boolean :accept_receive_updates, default: true
      t.integer :space_id
      t.integer :user_id

      t.timestamps
    end
  end
end
