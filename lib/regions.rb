# frozen_string_literal: true

module Regions
  REGIONS = YAML.load_file(Rails.root.join('config', 'regions.yml'))

  COUNTRY_ENUM_KEYS = Hash[REGIONS.map do |country_code, country_data|
    [country_data['name'], country_code]
  end]

  CITY_ENUM_KEYS = Hash[REGIONS.flat_map do |country_code, country_data|
    country_data['cities'].map do |city_code, city_data|
      [city_data['name'], "#{country_code}-#{city_code}"]
    end
  end]

  AREA_ENUM_KEYS = Hash[REGIONS.flat_map do |country_code, country_data|
    country_data['cities'].flat_map do |city_code, city_data|
      city_data['areas'].map do |area_code, area_data|
        [area_data['name'], "#{country_code}-#{city_code}-#{area_code}"]
      end
    end
  end]

  COUNTRY_CODES = Hash[REGIONS.map do |country_code, country_data|
    [country_data['name'], country_code]
  end]

  CITY_CODES = Hash[REGIONS.flat_map do |_country_code, country_data|
    country_data['cities'].map do |city_code, city_data|
      [city_data['name'], city_code]
    end
  end]

  AREA_CODES = Hash[REGIONS.flat_map do |_country_code, country_data|
    country_data['cities'].flat_map do |_city_code, city_data|
      city_data['areas'].map do |area_code, area_data|
        [area_data['name'], area_code]
      end
    end
  end]

  LatLng = Struct.new(:latitude, :longitude)

  AREA_LATLNG = Hash[REGIONS.flat_map do |_country_code, country_data|
    country_data['cities'].flat_map do |_city_code, city_data|
      city_data['latlng'].map do |area_name, area_latlng|
        [area_name, LatLng.new(area_latlng['latitude'], area_latlng['longitude'])]
      end
    end
  end]

  def self.currency(country)
    country_code = COUNTRY_CODES[country] || 'SGP'
    (REGIONS[country_code]['currency'] || 'SGD').downcase.to_sym
  end
end
