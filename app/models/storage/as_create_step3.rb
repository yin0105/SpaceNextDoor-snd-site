# frozen_string_literal: true

class Storage
  class AsCreateStep3 < ActiveType::Record[Form]
    has_one :space, class_name: 'Space::AsCreateStep3', as: :spaceable, dependent: :destroy, required: true

    validates :checkin_time, presence: true
    validates :rules, presence: true, blank_array: true
  end
end
