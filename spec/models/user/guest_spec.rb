# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Guest, type: :model do
  subject { create(:guest) }

  it { is_expected.to have_many(:orders) }
  it { is_expected.to have_many(:channels) }

  describe '#as_user' do
    it 'return a User instance' do
      expect(subject.as_user.class).to eq(User)
    end
  end

  describe '#last_week_signed_up' do
    before do
      create(:order)
      create(:order, guest: create(:guest, created_at: Time.current - 1.week))
    end

    it 'returns numbers of signups for last week' do
      expect(described_class.joins(:orders).last_week_signed_up.count).to eq(1)
    end
  end

  describe '#last_month_signed_up' do
    before do
      create(:order)
      create(:order, guest: create(:guest, created_at: Time.current - 1.month))
    end

    it 'returns numbers of signups for last month' do
      expect(described_class.joins(:orders).last_month_signed_up.count).to eq(1)
    end
  end

  describe '#no_active_orders' do
    before { create(:order, :completed, start_at: Time.zone.today - 5.days, end_at: Time.zone.today - 1.day) }

    it 'returns guests without active orders' do
      expect(described_class.no_active_orders.count).to eq(1)
    end
  end

  describe '#last_week_moved_out' do
    before do
      create(:order, :completed, start_at: Time.zone.today - 5.days, end_at: Time.zone.today - 1.day)
      guest = create(:user, :with_payment_method).as_guest
      create(:order, :completed, start_at: Time.zone.today - 5.days, end_at: Time.zone.today - 1.day, guest: guest)
      create(:order, start_at: Time.zone.today - 5.days, end_at: Time.zone.today + 1.day, guest: guest)
    end

    it 'returns guests moving out for the last week' do
      expect(described_class.last_week_moved_out.count).to eq(1)
    end
  end

  describe '#last_month_moved_out' do
    before do
      create(:order, :completed, start_at: Time.zone.today - 3.weeks, end_at: Time.zone.today - 2.weeks)
      guest = create(:user, :with_payment_method).as_guest
      create(:order, :completed, start_at: Time.zone.today - 3.weeks, end_at: Time.zone.today - 2.weeks, guest: guest)
      create(:order, start_at: Time.zone.today - 5.days, end_at: Time.zone.today + 1.day, guest: guest)
    end

    it 'returns guests moving out for the last month' do
      expect(described_class.last_month_moved_out.count).to eq(1)
    end
  end
end
