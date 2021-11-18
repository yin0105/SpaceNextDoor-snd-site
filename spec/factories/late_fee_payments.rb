# frozen_string_literal: true

FactoryBot.define do
  factory :late_fee_payment do
    order do
      create(:order, :with_payments, :completed)
    end

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

    trait :success do
      after(:create) do |payment, _|
        DoubleEntry.lock_accounts(*Accounting::LateFeePaymentService.new(payment).lock_accounts) do
          payment.succeed!
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
