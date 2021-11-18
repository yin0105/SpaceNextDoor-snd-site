# frozen_string_literal: true

class Storage
  class AsCreateStep2 < ActiveType::Record[Form]
    has_one :space, class_name: 'Space::AsCreateStep2', as: :spaceable, dependent: :destroy, required: true
  end
end
