# frozen_string_literal: true

class Storage
  class AsCreateStep1 < ActiveType::Record[Form]
    has_one :space, class_name: 'Space::AsCreateStep1', as: :spaceable, dependent: :destroy, required: true

    validates :category, :features, presence: true
    validates :features, blank_array: true
  end
end
