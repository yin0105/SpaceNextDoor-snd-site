# frozen_string_literal: true

class Space
  class AsCreateStep1 < ActiveType::Record[Space]
    validates :address, :property, presence: true
  end
end
