# frozen_string_literal: true

class Space
  class AsCreateStep3 < ActiveType::Record[Space]
    validates :minimum_rent_days, presence: true
  end
end
