# frozen_string_literal: true

class CreateNotification < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.references :admin, foreign_key: true
      t.text :content
      t.timestamps
    end
  end
end
