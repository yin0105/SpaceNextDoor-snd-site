# frozen_string_literal: true

class CreateUserAvatars < ActiveRecord::Migration[5.0]
  def change
    create_table :user_avatars do |t|
      t.references :user, foreign_key: true, index: true
      t.string :image

      t.timestamps
    end
  end
end
