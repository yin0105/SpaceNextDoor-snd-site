# frozen_string_literal: true

FactoryBot.define do
  factory :contact, class: 'Contact' do
    user { create(:user) }
    name { Faker::Name.name }
    phone { '+6581111111' }
    email { Faker::Internet.email }

    trait :host do
      type { :host }
    end

    trait :guest do
      type { :guest }
    end
  end
end
