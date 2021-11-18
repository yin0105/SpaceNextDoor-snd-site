# frozen_string_literal: true

class InsuranceReport < ActiveType::Record[Payment]
  default_scope -> { where.not(insurance_type: [nil, Insurance::NULL_INSURANCE_TYPE]) }
  scope :search_by_city, ->(city) { where(addresses: { city: city }) }
  scope :search_by_area, ->(area) { where(addresses: { area: area }) }
  scope :search_by_address, ->(street_address) { where('addresses.street_address LIKE ?', "%#{street_address}%") }

  def self.ransackable_scopes(_auth_object = nil)
    %i[search_by_city search_by_area search_by_address]
  end
end
