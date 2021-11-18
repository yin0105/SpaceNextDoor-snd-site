# frozen_string_literal: true

class Space
  class AsUpdate < ActiveType::Record[Space]
    validates :name, :description, :status, :daily_price, :minimum_rent_days, :images, presence: true
    validates :images, length: { minimum: 2, maximum: 6, message: 'please provide 2~6 photos' }
    monetize :daily_price_cents, numericality: { greater_than: 0 }
    # TODO: add validation to dates
  end
end
