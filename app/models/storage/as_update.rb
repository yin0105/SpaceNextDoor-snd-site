# frozen_string_literal: true

class Storage
  class AsUpdate < ActiveType::Record[Form]
    has_one :space, class_name: 'Space::AsUpdate', as: :spaceable, foreign_key: :spaceable_id, foreign_type: :spaceable_type, dependent: :destroy, required: true

    validates :checkin_time, :category, :features, presence: true
    validates :rules, presence: true, blank_array: true
  end
end
