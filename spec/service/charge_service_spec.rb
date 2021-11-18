# frozen_string_literal: true

require 'rails_helper'

describe 'ChargeService' do
  subject { CreatePaymentService.new(@order).start! }

  before(:all) { @space = create(:space, :activated, :two_years) }

  before do
    @order = create(:order, space: @space)
  end

  context 'stripe response success' do
    before { allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1) }

    it 'create a new payment' do
      expect { subject }.to change { @order.payments.count }.from(0).to(1)
    end

    it 'payment success' do
      subject
      expect(@order.payments.last.success?).to be true
    end
  end

  context 'stripe Card Error' do
    before do
      allow(Stripe::Charge).to receive(:create) do
        raise Stripe::CardError.new(
          'Your card is error!!!',
          'expired_card',
          json_body: { error: {
            code: 'card_declined',
            message: 'Your card was declined.',
            decline_code: 'expired_card'
          } }
        )
      end
    end

    it 'rescue card error and raise a new CardError' do
      expect { subject }.to raise_error(ChargeService::CardError)
    end
  end
end
