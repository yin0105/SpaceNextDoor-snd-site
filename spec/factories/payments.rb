# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    order { create(:order) }
    rent { order.price * order.next_service_days }
    service_start_at { order.next_service_start_at }
    service_end_at { order.next_service_end_at }
    payment_type { User::PaymentMethod::TYPES[:stripe] }
    identifier { Faker::Name.name }
    user { order.guest.as_user }
    guest_service_fee { rent * order.service_fee_guest_rate }
    host_service_fee { rent * order.service_fee_host_rate }
    serial { order.payments.count + 1 }
    deposit { order.price * Settings.deposit.days if serial == 1 }
    premium { order.premium }

    before(:create) do |payment, _|
      payment.service_start_at = payment.order.next_service_start_at
      payment.service_end_at = payment.order.next_service_end_at
      payment.rent = payment.order.price * payment.order.next_service_days
      payment.rent = payment.order.price * payment.order.days if payment.order.payoff?
    end

    trait :success do
      after(:create) do |payment, _|
        DoubleEntry.lock_accounts(*Accounting::PaymentService.new(payment).lock_accounts) do
          payment.succeed!
        end
      end
    end

    trait :fail do
      after(:create) do |payment, _|
        payment.retry!
        payment.fail!
      end
    end

    trait :retry do
      after(:create) do |payment, _|
        payment.retry!
      end
    end

    trait :resolved do
      after(:create) do |payment, _|
        payment.retry!
        payment.fail!

        DoubleEntry.lock_accounts(*Accounting::PaymentService.new(payment).lock_accounts) do
          payment.resolve!
        end
      end
    end

    trait :success_without_lock do
      after(:create) do |payment, _|
        payment.succeed!
      end
    end
  end
end
