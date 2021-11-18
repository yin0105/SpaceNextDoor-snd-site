# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  let(:fake_phone) { '6670-5255' }
  let(:invalid_fake_phone) { '1234-5678' }

  it { is_expected.to have_many(:evaluations) }
  it { is_expected.to allow_value(fake_phone).for(:phone) }
  it { is_expected.to allow_value(fake_phone).for(:unconfirmed_phone) }
  it { is_expected.not_to allow_value(invalid_fake_phone).for(:unconfirmed_phone) }

  describe '.from_omniauth' do
    def auth(hash = {})
      auth = { provider: 'facebook',
               uid: '1234567890',
               info: {
                 email: 'test@test.com',
                 first_name: 'first',
                 last_name: 'last'
               } }.merge(hash)
      JSON.parse(auth.to_json, object_class: OpenStruct)
    end

    context 'when user existed in db' do
      subject(:login_from_facebook) { create(:user, provider: 'facebook', uid: '1234567890') }

      it "won't create a new user" do
        login_from_facebook
        expect { described_class.from_omniauth(auth) }.to change(described_class, :count).by(0)
      end
    end

    context "when user didn't exist in db" do
      it 'create a new user' do
        expect { described_class.from_omniauth(auth) }.to change(described_class, :count).by(1)
        user = described_class.last
        expect(user.email).to eq('test@test.com')
        expect(user.first_name).to eq('first')
        expect(user.last_name).to eq('last')
      end
    end
  end

  describe '#phone' do
    it 'display as international format' do
      user[:phone] = fake_phone
      expect(user.phone).to eq(GlobalPhone.parse(fake_phone).international_format)
    end
  end

  describe '#phone_verified?' do
    it 'verified when phone present' do
      user[:phone] = fake_phone
      expect(user.phone_verified?).to eq true
    end

    it 'not verified when phone not present' do
      expect(user.phone_verified?).to eq false
    end
  end

  describe '#confirm_phone' do
    it 'copy unconfirmed_phone to phone' do
      user.unconfirmed_phone = fake_phone
      user.confirm_phone

      expect(user.phone).to eq(GlobalPhone.parse(fake_phone).international_format)
    end
  end

  describe '#unread_notification?' do
    subject { user.unread_notification? }

    context 'with 0 notification' do
      it { is_expected.to be_falsey }
    end

    context 'with 1 notification' do
      subject { user.unread_notification? }

      before { create(:notification) }

      context 'when user has no notifications_seen_at' do
        it { is_expected.to be_truthy }
      end

      context 'when last notifications_seen_at > notifications_seen_at' do
        before { user.notifications_seen_at = 2.days.ago }

        it { is_expected.to be_truthy }
      end

      context 'when last notifications_seen_at < notifications_seen_at' do
        before { user.notifications_seen_at = Time.zone.now }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#unread_message?' do
    # TODO: not to test it temporally, cause in order to create a chhanel,
    # it takes time to create a space. In this block, there are four situation to test.
  end
end
