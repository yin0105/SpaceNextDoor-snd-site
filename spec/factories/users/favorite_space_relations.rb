# frozen_string_literal: true

FactoryBot.define do
  factory :favorite_space_relation, class: 'User::FavoriteSpaceRelation' do
    user { create(:user) }
    space { create(:space) }

    trait :space_activated do
      space { create(:space, :activated) }
    end

    trait :space_deactivated do
      space { create(:space, :deactivated) }
    end

    trait :space_deleted do
      space { create(:space, :soft_deleted) }
    end
  end
end
