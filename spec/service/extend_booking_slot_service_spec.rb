# frozen_string_literal: true

require 'rails_helper'

describe 'ExtendBookingSlotService' do
  before do
    Schedule.aasm.state_machine.config.no_direct_assignment = false
  end

  let(:dates) { (Time.zone.today..(Time.zone.today + Settings.space.auto_extend_days - 1.day)).to_a }

  let(:space) { create(:space, dates: dates) }

  let(:service) { ExtendBookingSlotService.new(space) }

  describe '#start!' do
    subject { service.start! }

    it { is_expected.to be_truthy }
  end

  describe '#any?' do
    subject { service.any? }

    it { is_expected.to be_falsy }
  end

  describe '#events' do
    subject { service.events }

    let(:dates) { (Time.zone.today..(Time.zone.today + Settings.space.auto_extend_days)).to_a }

    let(:space) { create(:space, dates: dates) }

    it { is_expected.to be_empty }

    context 'has scheduled' do
      let(:event) do
        create(:schedule, status: :scheduled, event: :extend_booking_slot, schedulable_id: space,
                          schedulable_type: :space, schedulable: space)
      end

      it { is_expected.to match([event]) }
    end
  end
end
