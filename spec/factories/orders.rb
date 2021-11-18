# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    transient do
      number_of_days { Faker::Number.between(from: 31, to: 365) }
    end

    space { create(:space, :activated, :two_years) }
    price { space.daily_price }
    host { space.user.as_host }
    guest { create(:user, :with_payment_method).as_guest }
    start_at { Time.zone.today }
    end_at { start_at + [(number_of_days - 1), space.minimum_rent_days].max.days }
    premium { 0.to_money }
    insurance_enable { space.insurance_enable }
    rent_payout_type { 'ten_days' }

    trait :with_invalid_data do
      start_at { nil }
      end_at { nil }
    end

    trait :with_payments do
      after(:create) do |order, _|
        create(:payment, :success, order: order, user: order.guest.as_user)
      end
    end

    trait :with_failed_payments do
      after(:create) do |order, _|
        create(:payment, :fail, order: order, user: order.guest.as_user)
      end
    end

    trait :with_retry_payments do
      after(:create) do |order, _|
        create(:payment, :retry, order: order, user: order.guest.as_user)
      end
    end

    trait :with_resolved_payments do
      after(:create) do |order, _|
        create(:payment, :resolved, order: order, user: order.guest.as_user)
      end
    end

    trait :with_late_fee_payments do
      after(:create) do |order, _|
        create(:payment, :success, order: order, user: order.guest.as_user)
        create(:late_fee_payment, :success, order: order)
      end
    end

    trait :with_one_month_discount do
      discount_code { 1 }
    end

    trait :with_two_months_discount do
      discount_code { 2 }
    end

    trait :with_valid_one_month_discount do
      end_at { start_at + Faker::Number.between(from: 89, to: 365) }
      discount_code { 1 }
    end

    trait :with_valid_two_months_discount do
      end_at { start_at + Faker::Number.between(from: 179, to: 365) }
      discount_code { 2 }
    end

    trait :with_valid_six_months_discount do
      end_at { start_at + Faker::Number.between(from: 179, to: 365) }
      discount_code { 3 }
    end

    trait :payoff do
      end_at { start_at + Faker::Number.between(from: 7, to: 28).days }
    end

    trait :payoff_11_20_days do
      end_at { start_at + Faker::Number.between(from: 10, to: 19).days }
    end

    trait :payoff_21_29_days do
      end_at { start_at + Faker::Number.between(from: 20, to: 28).days }
    end

    trait :with_one_month_rent_payout_type do
      rent_payout_type { 'one_month' }
    end

    trait :with_ten_days_rent_payout_type do
      rent_payout_type { 'ten_days' }
    end

    trait :instalment do
      end_at { start_at + (Faker::Number.between(from: 61, to: 365) - 1).days }
    end

    trait :with_refund do
      long_term_cancelled_at { start_at + Settings.order.days_to_next_service_end.days }
    end

    trait :will_start_in_7_days do
      start_at { Time.zone.today + 7.days }
    end

    trait :will_start_between_8_and_14_days do
      start_at { Time.zone.today + 9.days }
    end

    trait :will_start_after_14_days do
      start_at { Time.zone.today + 16.days }
    end

    trait :with_no_refund do
      long_term_cancelled_at { next_service_end_at }
    end

    trait :cancelled do
      after(:create) do |order, _|
        order.cancel!
      end
    end

    trait :active do
      after(:create) do |order, _|
        unless order.active?
          order.activate!
          order.remain_payment_cycle -= 1
          order.save!
        end
      end
    end

    trait :completed do
      after(:create) do |order, _|
        order.activate! unless order.active?
        order.complete!
      end
    end

    trait :reviewed do
      note { Faker::Lorem.paragraphs.join(' ') }
      damage_fee { Faker::Number.number(digits: 3).to_money }
      after(:create) do |order, _|
        order.complete!
        DoubleEntry.lock_accounts(*Accounting::OrderReviewService.new(order).lock_accounts) do
          order.review!
        end
      end
    end

    trait :rated do
      after(:create) do |order, _|
        order.ratings.each do |rating|
          rating.update(rate: (1..5).to_a.sample)
        end
      end
    end

    trait :long_term do
      long_term { true }
    end

    trait :long_term_cancelled_at do
      long_term_cancelled_at { start_at + (Faker::Number.between(from: 31, to: 365) - 1).days }
    end

    trait :without_end_at do
      end_at { nil }
    end

    trait :with_premium do
      premium { Faker::Number.number(digits: 2).to_money }
    end

    trait :insurance_enable do
      insurance_enable { true }
      insurance_type { Insurance::INSURANCE_OPTIONS.keys.sample }
      premium { Insurance.premium(insurance_type) }
    end

    trait :insurance_disable do
      insurance_enable { false }
      insurance_type { Insurance::NULL_INSURANCE_TYPE }
      premium { Insurance.premium(insurance_type) }
    end

    trait :rent_upto_179_days do
      end_at { start_at + Faker::Number.between(from: 1, to: 179).days }
    end

    trait :rent_more_then_180_days do
      end_at { start_at + Faker::Number.between(from: 180, to: 364).days }
    end
  end
end
