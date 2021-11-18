# frozen_string_literal: true

FactoryBot.define do
  factory :direct_order do
    transient do
      number_of_days { Faker::Number.between(from: 31, to: 365) }
    end

    space { create(:space, :activated, :two_years) }
    price { space.daily_price }
    host { space.user.as_host }
    guest { create(:user, :with_payment_method, :with_phone).as_guest }
    start_at { Time.zone.today }
    end_at { start_at + [(number_of_days - 1), space.minimum_rent_days].max.days }
    insurance_enable { false }
    insurance_type { 'coverage_null' }
    premium { 0.to_money }
  end
end
