# frozen_string_literal: true

FactoryBot.define do
  factory :payment_method, class: 'User::PaymentMethod' do
    type { :stripe }
    identifier { Faker::Name.name }
    expiry_date { Faker::Date.between(from: 1.year.from_now, to: 10.years.from_now) }
    token { Faker::Internet.password(min_length: 8) }
    user { create(:user) }
  end
end
