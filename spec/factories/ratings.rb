# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    transient do
      target { %i[guest host space].sample }
    end

    order { create(:order) }
    ratable { order.send(target) }
    user { target == :guest ? order.host : order.guest }

    trait :completed do
      rate { (Faker::Number.between(from: 0.0, to: 5.0) / 0.5).round * 0.5 }
      note { Faker::Lorem.paragraphs.join(' ') }
    end
  end
end
