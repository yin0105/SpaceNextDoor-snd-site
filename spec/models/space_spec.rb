# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Space, type: :model do
  subject(:build_space) { build(:space) }

  before { described_class.aasm.state_machine.config.no_direct_assignment = false }

  it_behaves_like 'HasAddress'
  it_behaves_like 'Imageable'
  it { is_expected.to validate_presence_of(:status) }

  describe 'dates' do
    it 'accepts string argument and return an array of dates' do
      dates_count = build_space.dates.count
      build_space.booking_slots.last.status = :disabled
      expect(build_space.dates.count).not_to eq(dates_count)
    end
  end

  describe '#dates=' do
    it 'accepts string argument and return an array of dates' do
      dates = (2.days.ago.to_date..10.days.from_now.to_date).to_a
      build_space.dates = dates.join('; ')
      expect(build_space.dates).to include(*dates)
    end
  end

  describe '#available_dates' do
    subject(:space) { create(:space, :activated, :two_years) }

    it 'return the rest of available dates' do
      disabled_dates = [*Time.zone.today..30.days.from_now.to_date]
      space.booking_slots.where(date: disabled_dates).update(status: :booked)
      space.reload
      expect(space.available_dates).to contain_exactly(*(space.dates - disabled_dates))
    end
  end

  describe 'lifecycle callbacks' do
    describe '#submit!' do
      before { build_space.save }

      it { is_expected.to transition_from(:draft).to(:pending).on_event(:submit) }

      it { is_expected.not_to transition_from(:activated).to(:pending).on_event(:submit) }
      it { is_expected.not_to transition_from(:soft_deleted).to(:pending).on_event(:submit) }
      it { is_expected.not_to transition_from(:deactivated).to(:pending).on_event(:submit) }
      it { is_expected.not_to transition_from(:disapproved).to(:pending).on_event(:submit) }
    end

    describe '#approve!' do
      let(:space) { create(:space, status: :pending) }

      it { is_expected.to transition_from(:pending).to(:activated).on_event(:approve) }

      it { is_expected.not_to transition_from(:draft).to(:activated).on_event(:approve) }
      it { is_expected.not_to transition_from(:soft_deleted).to(:activated).on_event(:approve) }
      it { is_expected.not_to transition_from(:deactivated).to(:activated).on_event(:approve) }
      it { is_expected.not_to transition_from(:disapproved).to(:activated).on_event(:approve) }

      it 'call send_notification least once' do
        expect(space).to receive(:send_notification).at_least(:once)
        space.approve!
      end
    end

    describe '#disapprove!' do
      let(:space) { create(:space) }

      it { is_expected.to transition_from(:pending).to(:disapproved).on_event(:disapprove) }

      it { is_expected.not_to transition_from(:draft).to(:disapproved).on_event(:disapprove) }
      it { is_expected.not_to transition_from(:activated).to(:disapproved).on_event(:disapprove) }
      it { is_expected.not_to transition_from(:soft_deleted).to(:disapproved).on_event(:disapprove) }
      it { is_expected.not_to transition_from(:deactivated).to(:disapproved).on_event(:disapprove) }
    end

    describe '#hide!' do
      subject(:space) { create(:space) }

      it { is_expected.to transition_from(:activated).to(:deactivated).on_event(:hide) }

      it { is_expected.not_to transition_from(:draft).to(:deactivated).on_event(:hide) }
      it { is_expected.not_to transition_from(:pending).to(:deactivated).on_event(:hide) }
      it { is_expected.not_to transition_from(:soft_deleted).to(:deactivated).on_event(:hide) }
      it { is_expected.not_to transition_from(:disapproved).to(:deactivated).on_event(:hide) }
    end

    describe '#show!' do
      subject(:space) { create(:space) }

      it { is_expected.to transition_from(:deactivated).to(:activated).on_event(:show) }

      it { is_expected.not_to transition_from(:draft).to(:activated).on_event(:show) }
      it { is_expected.not_to transition_from(:pending).to(:activated).on_event(:show) }
      it { is_expected.not_to transition_from(:soft_deleted).to(:activated).on_event(:show) }
      it { is_expected.not_to transition_from(:disapproved).to(:activated).on_event(:show) }
    end

    describe '#delete!' do
      subject(:space) { create(:space) }

      it { is_expected.to transition_from(:draft).to(:soft_deleted).on_event(:soft_delete) }
      it { is_expected.to transition_from(:activated).to(:soft_deleted).on_event(:soft_delete) }
      it { is_expected.to transition_from(:deactivated).to(:soft_deleted).on_event(:soft_delete) }

      it { is_expected.not_to transition_from(:pending).to(:soft_deleted).on_event(:soft_delete) }
      it { is_expected.not_to transition_from(:disapproved).to(:soft_deleted).on_event(:soft_delete) }
    end
  end

  describe 'auto extend slots' do
    subject(:last_booking_slots) { space.booking_slots.last.date }

    let(:dates) { (Time.zone.today..(Time.zone.today + Settings.space.auto_extend_days - 1.day)).to_a }
    let(:space) { create(:space, dates: dates) }

    before { ExtendBookingSlotService.new(space).start! }

    it { is_expected.to be >= 1.year.from_now }

    describe 'has extend schedule' do
      subject(:extend_booking_slot_schedule) { space.schedules.extend_booking_slot.scheduled.any? }

      it { is_expected.to be_truthy }
    end

    context 'when no need to extend' do
      let(:dates) { (Time.zone.today..(Time.zone.today + Settings.space.auto_extend_days)).to_a }

      let(:space) { create(:space, dates: dates) }

      it { is_expected.to be < 1.year.from_now }
    end

    context 'without long lease order' do
      it 'status is available' do
        create(:order, :with_payments, :payoff, space: space)

        expect(space.booking_slots.available.size).to be >= 365
      end
    end

    context 'with long lease order' do
      it 'status is booked' do
        create(:order, :with_payments, :instalment, space: space)

        expect(space.booking_slots.booked.size).to be >= 365
      end
    end
  end

  describe '#build_up_area' do
    let!(:spaces) { create_list(:space, 2) }

    it 'returns total build-up area' do
      expect(described_class.build_up_area).to eq(spaces.reduce(0) { |sum, space| space.area + sum })
    end
  end

  describe '#total_available_area' do
    before { create_list(:order, 2, :active) }

    let!(:available_spaces) { create_list(:space, 2) }

    it 'returns total available area' do
      occupied_area = available_spaces.reduce(0) { |sum, space| space.area + sum }
      expect(described_class.available_area).to eq(occupied_area)
    end
  end

  describe '#total_occupancy' do
    before do
      create_list(:space, 2)
    end

    it 'returns occupied area' do
      orders = create_list(:order, 2, :active)
      occupied_area = orders.reduce(0) { |sum, order| order.space.area + sum }
      expect(described_class.occupied_area).to eq(occupied_area)
    end
  end

  describe '#available_by_area' do
    let(:address) { create(:address) }
    let(:address2) { create(:address, area: address.area) }

    it 'returns available spaces by area' do
      create(:space, address: address)
      create(:space, address: address2)
      expect(described_class.available_by_area(address.area)).to eq(2)
    end
  end

  describe '#booked_by_area' do
    let(:address) { create(:address) }
    let(:address2) { create(:address, area: address.area) }
    let(:space) { create(:space, address: address) }
    let(:space2) { create(:space, address: address2) }

    it 'returns booked spaces by area' do
      create(:order, :active, space: space)
      create(:order, :active, space: space2)
      expect(described_class.booked_by_area(address.area)).to eq(2)
    end
  end
end
