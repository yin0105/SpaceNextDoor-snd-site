# frozen_string_literal: true

FactoryBot.define do
  factory :find_out_request do
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
    location { Regions::AREA_CODES.keys.sample }
    start_at { Faker::Date.between(from: 5.days.from_now, to: 30.days.from_now) }
    end_at { Faker::Date.between(from: 31.days.from_now, to: 1.year.from_now) }
    description { Faker::Lorem.paragraph }
    size { Random.rand(1..100) }
  end
end
