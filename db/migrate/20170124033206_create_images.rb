# frozen_string_literal: true

class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.string :imageable_type
      t.integer :imageable_id
      t.string :image
      t.string :secure_token
      t.integer :width
      t.integer :height

      t.timestamps
    end

    add_index :images, %i[imageable_type imageable_id]
    add_index :images, :secure_token, unique: true
  end
end
