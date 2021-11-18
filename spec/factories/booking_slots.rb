# frozen_string_literal: true

FactoryBot.define do
  factory :booking_slot do
    space { create(:space) }
    sequence(:date, Faker::Number.between(from: 0, to: 100)) { |n| Time.zone.today + n }

    trait :booked do
      status { :booked }
    end
  end
end
