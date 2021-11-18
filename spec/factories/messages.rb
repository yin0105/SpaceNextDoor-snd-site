# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    channel { create(:channel) }
    user { channel.send %w[guest host].sample.to_sym }
    content { Faker::Lorem.paragraphs.join(' ') }

    trait :with_image do
      after(:create) do |message, _|
        message.images.create! attributes_for(:image)
      end
    end
  end
end
