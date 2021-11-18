# frozen_string_literal: true

class Storage
  class AsUpdateCalendar < ActiveType::Record[Form]
    has_one :space, class_name: 'Space::AsUpdateCalendar', as: :spaceable, foreign_key: :spaceable_id, foreign_type: :spaceable_type, dependent: :destroy, required: true
  end
end
