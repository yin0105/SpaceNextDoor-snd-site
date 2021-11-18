# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    confirmed_at { Time.zone.now }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :with_payment_method do
      payment_method { create(:payment_method) }
    end

    trait :with_bank_account do
      after(:create) do |user|
        create(:bank_account, user: user)
      end
    end

    trait :with_phone do
      after(:create) do |user|
        user.phone = '+6581111111'
        user.confirm_phone
      end
    end

    trait :without_confirmation do
      confirmed_at { nil }
    end

    trait :with_guest_contact do
      after(:create) do |user|
        create(:contact, user: user, type: :guest)
      end
    end

    trait :with_host_contact do
      after(:create) do |user|
        create(:contact, user: user, type: :host)
      end
    end

    after(:create) do |user|
      user.password = nil
    end
  end
end
