# frozen_string_literal: true

FactoryBot.define do
  factory :channel do
    transient do
      sender { %i[guest host].sample }
    end

    space { create(:space, :activated, :two_years) }
    guest { create(:guest) }
    host { space.user.as_host }

    trait :with_orders do
      after(:create) do |channel, _|
        create(:order, space: channel.space, channel: channel, guest: channel.guest)
      end
    end

    trait :with_completed_orders do
      after(:create) do |channel, _|
        create(:order, :completed, space: channel.space, channel: channel, guest: channel.guest)
      end
    end

    trait :with_messages do
      after(:create) do |channel, factory|
        create_list(:message, 2, channel: channel, user: channel.send(factory.sender).as_user)
      end
    end
  end
end
