# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Channel, type: :model do
  subject { create(:channel, space: @space) }

  before(:all) { @space = create(:space, :activated) }

  it { is_expected.to belong_to(:guest) }
  it { is_expected.to belong_to(:space) }
  it { is_expected.to have_many(:orders) }
  it { is_expected.to have_many(:messages) }

  describe 'validation' do
    subject { build(:channel, space: @space, guest: @space.user.as_guest) }

    it 'host cannot contact himself' do
      expect(subject).to be_invalid
    end
  end

  describe '#unrated_orders' do
    let!(:order) { create(:order, :completed, space: @space, guest: subject.guest) }
    let!(:unrated_orders) { create(:order, :completed, :rated, space: @space, guest: subject.guest) }

    it 'return all unrated orders' do
      expect(subject.unrated_orders.count).to eq(1)
    end
  end

  describe '#pending_order?' do
    context 'there is a pending order' do
      let!(:order) { create(:order, channel: subject, space: @space) }

      it 'return true' do
        expect(subject).to be_pending_order
      end
    end

    context "there isn't any pending order" do
      let!(:order) { create(:order, :active, channel: subject, space: @space) }

      it 'return false' do
        expect(subject).not_to be_pending_order
      end
    end
  end

  describe '#create_system_message' do
    it 'return a system message' do
      subject.create_system_message(Time.zone.now, 10.days.from_now)
      expect(subject.messages.first).to be_sent_by_system
    end

    it 'return false if not a system-maded message' do
      create(:message, channel: subject)
      expect(subject.messages.first).not_to be_sent_by_system
    end
  end
end
