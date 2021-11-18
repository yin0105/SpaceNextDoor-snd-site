# frozen_string_literal: true

class Rating
  class MultipleUpdateForm < ActiveType::Object
    nests_many :ratings, scope: proc { Rating.all }
  end
end
