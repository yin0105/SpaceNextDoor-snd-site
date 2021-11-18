# frozen_string_literal: true

FactoryBot.define do
  factory :space do
    transient do
      without_storage { false }
    end

    name { Faker::Games::Pokemon.name }
    user { create(:user, :with_bank_account) }
    description { Faker::Lorem.sentence }
    images { create_list(:image, 2) }
    area { Faker::Number.number(digits: 2) }
    daily_price { Faker::Number.number(digits: 2).to_money }
    minimum_rent_days { 7 }
    dates { (Time.zone.today..Faker::Date.between(from: minimum_rent_days.days.from_now, to: 1.year.from_now)).to_a }
    address { create(:address) }
    property { Space::PROPERTY.values.sample }
    insurance_enable { false }
    rent_payout_type { 'ten_days' }

    after(:create) do |space, evaluator|
      create(:storage, space: space, user: space.user) unless evaluator.without_storage
    end

    trait :pending do
      after(:create) do |instance, _|
        instance.submit!
      end
    end

    trait :activated do
      after(:create) do |instance, _|
        instance.submit!
        instance.approve!
      end
    end

    trait :deactivated do
      after(:create) do |instance, _|
        instance.submit!
        instance.approve!
        instance.hide!
      end
    end

    trait :soft_deleted do
      after(:create) do |instance, _|
        instance.soft_delete!
      end
    end

    trait :one_month do
      dates { (Time.zone.today...1.month.from_now.to_date).to_a }
    end

    trait :one_year do
      dates { (Time.zone.today..1.year.from_now.to_date).to_a }
    end

    trait :two_years do
      dates { (Time.zone.today..2.years.from_now.to_date).to_a }
    end

    trait :two_days do
      dates { (Time.zone.today..1.day.from_now.to_date).to_a }
    end

    trait :auto_extend_slot do
      auto_extend_slot { true }
    end

    trait :insurance_enable do
      insurance_enable { true }
    end

    trait :insurance_disable do
      insurance_enable { false }
    end

    trait :default_insurance_disable_property do
      property { 'residential' }
    end

    trait :default_insurance_enable_property do
      property { 'commercial' }
    end

    trait :featured do
      featured { true }
    end
  end
end
