# frozen_string_literal: true

FactoryBot.define do
  factory :payout do
    payment { create(:payment, :success) }
    user { payment.order.host.as_user }

    # default is payout for host rent
    type { :rent }
    amount { payment.host_rent }

    trait :damage do
      type { :damage }
      amount { payment.order.damage_fee }
    end

    trait :deposit do
      type { :deposit }
      amount { payment.deposit }
      user { payment.user }
    end

    trait :refund do
      type { :refund }
      amount { payment.refund }
      user { payment.user }
    end

    trait :rent_payout_cycle do
      type { :rent }
      start_at { payment.payout_start_at }
      end_at { payment.payout_end_at }
      amount { payment.payout_rent }
    end
  end
end
