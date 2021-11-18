# frozen_string_literal: true

class Storage
  class AsCreateStep5 < ActiveType::Record[Form]
    has_one :space, class_name: 'Space::AsCreateStep5', as: :spaceable, dependent: :destroy, required: true
  end
end
