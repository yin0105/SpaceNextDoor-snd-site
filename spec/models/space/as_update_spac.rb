# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Space::AsUpdate, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:booking_slots) }
  it { is_expected.to validate_presence_of(:minimum_rent_days) }
  it { is_expected.to monetize(:daily_price) }
  it { is_expected.not_to allow_value(0).for(:daily_price) }
  it { is_expected.to allow_value((1.day.from_now.to_date..10.days.from_now.to_date)).for(:dates) }
  it { is_expected.not_to allow_value((5.days.ago.to_date..5.days.from_now.to_date)).for(:dates) }
end
