# frozen_string_literal: true

class User
  class FavoriteSpaceRelation < ApplicationRecord
    belongs_to :user
    belongs_to :space

    validates :space_id, uniqueness: { scope: :user_id, message: 'no duplicate favorite space' }
  end
end
