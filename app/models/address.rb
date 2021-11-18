# frozen_string_literal: true

class Address < ApplicationRecord
  enum country: Regions::COUNTRY_ENUM_KEYS, _prefix: true
  enum city: Regions::CITY_ENUM_KEYS, _prefix: true
  enum area: Regions::AREA_ENUM_KEYS, _prefix: true

  belongs_to :addressable, polymorphic: true, optional: true
  validates :country, :city, :area, :street_address, :unit, presence: true
  acts_as_geolocated

  scope :in, ->(zone) { where(country: zone).or(where(city: zone)).or(where(area: zone)) }

  before_validation :reset_google_geocode_data_if_needed
  before_validation :auto_detect_area
  before_validation :geocode

  def full
    case country
    when 'Singapore'
      full = []
      full << "#{street_address},"
      full << "#{unit}," if unit.present?
      full << "#{area},"
      full << 'Singapore'
      full << postal_code
      full.join("\n")
    when 'Taiwan'
      [
        street_address,
        "#{area} #{city}",
        'Taiwan, R. O. C.'
      ].join("\n")
    else
      ''
    end
  end

  def location
    [area, city].join(' - ')
  end

  def position
    @position ||= OpenStruct.new(latitude: latitude || 0, longitude: longitude || 0)
  end

  def google_geocode_data
    @google_geocode_data ||= Google::Geocoding.geocode(address: to_s)
  end

  def to_s
    full
  end

  def self.areas
    distinct.pluck(:area)
  end

  private

  def reset_google_geocode_data_if_needed
    return unless country_changed? || city_changed? || area_changed? || street_address_changed?

    @google_geocode_data = nil
  end

  def auto_detect_area
    self.area = google_geocode_data[:area] if area.blank?
  rescue ArgumentError
    Rails.logger.warn "Address(id: #{id})#auto_detect_area: area #{google_geocode_data[:area]} is not available"
  end

  def geocode
    self.latitude = google_geocode_data[:latitude]
    self.longitude = google_geocode_data[:longitude]
  end
end
