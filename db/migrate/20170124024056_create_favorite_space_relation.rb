# frozen_string_literal: true

class CreateFavoriteSpaceRelation < ActiveRecord::Migration[5.0]
  def change
    create_table :user_favorite_space_relations do |t|
      t.belongs_to :user, index: true
      t.belongs_to :space, index: true
    end
  end
end
