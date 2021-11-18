# frozen_string_literal: true

class CreateRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :ratings do |t|
      t.belongs_to :ratable, polymorphic: true
      t.float :rate
      t.belongs_to :user, foreign_key: true
      t.belongs_to :message, foreign_key: true
      t.belongs_to :order, foreign_key: true
      t.boolean :completed
      t.text :note

      t.timestamps
    end
  end
end
