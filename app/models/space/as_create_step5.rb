# frozen_string_literal: true

class Space
  class AsCreateStep5 < ActiveType::Record[Space]
    validates :discount_code, if: -> { discount_code.present? }, numericality: { only_integer: true }
  end
end
