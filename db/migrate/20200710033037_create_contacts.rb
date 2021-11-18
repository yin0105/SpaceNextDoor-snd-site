# frozen_string_literal: true

class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.references :user, foreign_key: true
      t.integer :type
      t.string :name
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
