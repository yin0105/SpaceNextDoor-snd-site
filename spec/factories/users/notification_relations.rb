# frozen_string_literal: true

FactoryBot.define do
  factory :notification_relation, class: 'User::NotificationRelation' do
    user { create(:user) }
    notification { create(:notification, :with_user_relations) }
  end
end
