# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    admin { create(:admin) }
    title { Faker::Lorem.characters(number: 10) }
    content { Faker::Lorem.paragraphs.join(' ') }
    notify_type { 0 }
  end

  trait :with_user_relations do
    notify_type { Random.rand(1..4) }
  end
end
