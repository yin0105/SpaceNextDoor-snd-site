# frozen_string_literal: true

FactoryBot.define do
  factory :storage do
    user { create(:user) }
    space { create(:space, user: user) }
    category { 1 }
    features { [1, 2, 3] }
    rules { [1] }
    edit_status { 16 }

    trait :activated do
      space { create(:space, :activated, user: user) }
    end
  end
end
