# frozen_string_literal: true

class Space
  class AsCreateStep4 < ActiveType::Record[Space]
    monetize :daily_price_cents, numericality: { greater_than: 0 }
  end
end
