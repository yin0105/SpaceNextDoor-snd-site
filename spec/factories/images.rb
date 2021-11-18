# frozen_string_literal: true

FactoryBot.define do
  factory :image do
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'fake_image.jpg')) }

    trait :for_test do
      image { nil }
    end
  end
end
