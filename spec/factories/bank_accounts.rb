# frozen_string_literal: true

FactoryBot.define do
  factory :bank_account do
    user { create(:user) }
    country { Regions::COUNTRY_CODES.keys.sample }
    bank_code { Faker::Number.number(digits: 4) }
    account_name { Faker::Name.unique.name }
    account_number { Faker::Number.number(digits: 10) }
    bank_name { Faker::Name.unique.name }
    branch_code { Faker::Number.number(digits: 4) }
  end
end
