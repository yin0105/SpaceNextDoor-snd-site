# frozen_string_literal: true

class User
  class SearchSpace < ActiveType::Object
    attribute :region, :string
    attribute :field, :string

    def initialize(params = {})
      super
    end
  end
end
