# frozen_string_literal: true

FactoryBot.define do
  factory :verification_code do
    user { create(:user) }
    type { :phone }
  end
end
