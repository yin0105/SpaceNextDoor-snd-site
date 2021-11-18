# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VerificationCode, type: :model do
  let(:user) { create(:user) }

  it { is_expected.to validate_presence_of(:type) }

  describe '#expiry?' do
    it 'generated more than 5 minutes' do
      subject.expiry_at = 5.minutes.ago
      expect(subject.expiry?).to be true
    end
  end

  describe '#active?' do
    it 'generated less than 5.minutes' do
      subject.expiry_at = 5.minutes.from_now
      expect(subject.active?).to be true
    end
  end

  describe '#verify' do
    context 'phone' do
      subject { create(:verification_code, user: user) }

      before { allow(SmsService).to receive_message_chain(:new, :send_out) }

      it 'call User#confirm_phone and expiry it self' do
        subject.verify
        expect(subject.expiry?).to be true
      end
    end
  end

  describe '.latest' do
    context 'phone' do
      before { allow(SmsService).to receive_message_chain(:new, :send_out) }

      it 'has latest code' do
        create_list(:verification_code, 5, user: user)
        code = create(:verification_code, user: user)
        expect(user.verification_codes.latest(:phone)).to eq(code)
      end
    end
  end

  context 'phone verification' do
    it 'send SMS' do
      service = double(SmsService)
      allow(SmsService).to receive(:new).and_return(service)
      expect(service).to receive(:send_out)

      user.verification_codes.create!(type: :phone)
    end
  end
end
