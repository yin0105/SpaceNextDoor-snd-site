# frozen_string_literal: true

require 'rails_helper'

describe 'LateFeePaymentServiceSpec' do
  subject { payment_service.start! }

  before do
    LateFeePayment.aasm.state_machine.config.no_direct_assignment = false
    Order.aasm.state_machine.config.no_direct_assignment = false
  end

  let(:payment) { create(:late_fee_payment) }
  let(:payment_service) { LateFeePaymentService.new(payment) }

  context 'stripe response success' do
    before { allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1) }

    it 'create a new payment' do
      expect(payment.order.payments.count).to eq(2)
    end

    it 'payment success' do
      subject
      expect(payment.success?).to be true
    end

    describe 'send notification' do
      it 'call #send_notification' do
        expect_any_instance_of(LateFeePayment).to receive(:send_notification).at_least(:once)
        subject
      end
    end
  end

  context 'stripe Card Error' do
    before do
      allow(Stripe::Charge).to receive(:create) do
        raise Stripe::CardError.new(
          'Your card is error!!!',
          'expired_card', '',
          json_body: { error: {
            code: 'card_declined',
            message: 'Your card was declined.',
            decline_code: 'expired_card'
          } }
        )
      end
    end
  end
end
