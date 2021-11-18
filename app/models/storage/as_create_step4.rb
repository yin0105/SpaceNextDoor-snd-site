# frozen_string_literal: true

class Storage
  class AsCreateStep4 < ActiveType::Record[Form]
    has_one :space, class_name: 'Space::AsCreateStep4', as: :spaceable, dependent: :destroy, required: true
  end
end
