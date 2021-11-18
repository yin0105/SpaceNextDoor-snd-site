# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  subject { create(:message, channel: @channel) }

  before(:all) do
    @space = create(:space, :two_years, :activated)
    @channel = create(:channel, space: @space)
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:channel) }
  it { is_expected.to have_many(:images) }

  describe 'default_scope' do
    let(:message) { create(:message, channel: @channel) }

    it 'order id in descending way' do
      subject
      expect(@channel.messages).to eq([message, subject])
    end
  end

  describe 'validation' do
    context 'when somebody change channel_id' do
      subject { described_class.new(FactoryBot.attributes_for(:message, channel: channel, user: somebody)) }

      let!(:channel) { create(:channel, space: @space) }
      let!(:somebody) { create(:user) }

      it "message shouldn't be created" do
        expect(subject).to be_invalid
      end
    end
  end

  # please add test data to 'config/fake_phones.txt'
  describe '#remove_phone' do
    before do
      @messages = []
      phones = File.readlines(Rails.root.join('spec', 'fixtures', 'fake_phones.txt')).map!(&:strip)
      phones.each do |p|
        @messages << create(:message, channel: @channel, content: p)
      end
    end

    it 'removes all sensitive data' do
      @messages.each do |message|
        expect(message.content).to eq(described_class::ALARMING_WORDING)
      end
    end
  end

  describe '#remove_email' do
    let!(:message) { create(:message, channel: @channel, content: 'testtest+sg@testtest.com') }

    it 'removes all sensitive data' do
      expect(message.content).to eq(described_class::ALARMING_WORDING)
    end
  end
end
