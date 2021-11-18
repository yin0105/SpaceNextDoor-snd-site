# frozen_string_literal: true

require 'rails_helper'

describe 'VerifyPaymentService' do
  subject { VerifyPaymentService.new(payment).start! }

  before do
    allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1)
    Order.aasm.state_machine.config.no_direct_assignment = false
  end

  let(:order) { create(:order, :with_payments) }
  let(:payment) { InitializePaymentService.new(order).start! }

  describe 'verify' do
    context 'order with no remain payment should raise no remain payment error' do
      before { order.update(remain_payment_cycle: 0) }

      it { expect { subject }.to raise_error(VerifyPaymentService::NoRemainPaymentError) }
    end

    context 'charge at cancellation date should raise cancelled payment error' do
      before { order.update(long_term_cancelled_at: Time.zone.today) }

      it { expect { subject }.to raise_error(VerifyPaymentService::CancelledPaymentError) }
    end

    context 'charge a cancelled order should raise OrderStatusError' do
      before { order.update(status: :cancelled) }

      it { expect { subject }.to raise_error(VerifyPaymentService::OrderStatusError) }
    end

    context 'charge a completed order should raise OrderStatusError' do
      before { order.update(status: :completed) }

      it { expect { subject }.to raise_error(VerifyPaymentService::OrderStatusError) }
    end

    context 'charge a reviewed order should raise OrderStatusError' do
      before { order.update(status: :reviewed) }

      it { expect { subject }.to raise_error(VerifyPaymentService::OrderStatusError) }
    end

    context 'charge a early_ended order should raise OrderStatusError' do
      before { order.update(status: :early_ended) }

      it { expect { subject }.to raise_error(VerifyPaymentService::OrderStatusError) }
    end

    context 'charge a full_refunded order should raise OrderStatusError' do
      before { order.update(status: :full_refunded) }

      it { expect { subject }.to raise_error(VerifyPaymentService::OrderStatusError) }
    end
  end
end
