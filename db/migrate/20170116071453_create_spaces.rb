# frozen_string_literal: true

class CreateSpaces < ActiveRecord::Migration[5.0]
  def change
    create_table :spaces do |t|
      t.string :name
      t.text :description
      t.references :user, foreign_key: true
      t.integer :status, default: 0
      t.date :available_date, array: true, default: []
      t.boolean :required_govid, default: false

      t.timestamps
    end
  end
end
