# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    country { Regions::COUNTRY_CODES.keys.sample }
    city { Regions::REGIONS[Regions::COUNTRY_CODES[country]]['cities'].values.map { |v| v['name'] }.sample }
    area { Regions::REGIONS[Regions::COUNTRY_CODES[country]]['cities'][Regions::CITY_CODES[city]]['areas'].values.map { |v| v['name'] }.reject(&:blank?).sample }
    street_address { Faker::Address.street_address }
    postal_code { Faker::Address.postcode }
    unit { Faker::Address.secondary_address }
    association :addressable, factory: :user
  end
end
