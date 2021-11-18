# frozen_string_literal: true

class Space
  class AsCreateStep2 < ActiveType::Record[Space]
    validates :name, :description, :images, :area, presence: true
    validates :images, length: { minimum: 2, maximum: 6, message: 'please provide 2~6 photos' }
  end
end
