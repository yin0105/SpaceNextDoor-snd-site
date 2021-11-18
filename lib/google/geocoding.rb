# frozen_string_literal: true

module Google
  module Geocoding
    def self.geocode(address: nil)
      require 'net/http'
      require 'net/https'

      uri = URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape(address || '')}&key=#{Settings.google.api_key}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      req = Net::HTTP::Get.new(uri)
      res = http.request(req)

      raw_data = JSON.parse(res.body)
      parse_data(raw_data)
    end

    def self.parse_data(raw_data)
      data = { raw: raw_data }

      (raw_data.dig('results', 0, 'address_components') || []).each do |address_component|
        case address_component['types'][0]
        when 'street_number'
          data[:street_number] = address_component['long_name']
        when 'route'
          data[:street_name] = address_component['long_name']
        when 'neighborhood'
          data[:area] = address_component['long_name']
        when 'administrative_area_level_3'
          data[:area] = address_component['long_name']
        when 'locality'
          data[:city] = address_component['long_name']
        when 'administrative_area_level_1'
          data[:city] = address_component['long_name']
        end
      end

      data[:latitude] = raw_data.dig('results', 0, 'geometry', 'location', 'lat')
      data[:longitude] = raw_data.dig('results', 0, 'geometry', 'location', 'lng')

      data
    end
  end
end
