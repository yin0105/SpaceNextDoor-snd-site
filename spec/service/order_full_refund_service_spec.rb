# frozen_string_literal: true

require 'rails_helper'

describe 'OrderFullRefundServiceSpec' do
  subject(:order_full_refund) { OrderFullRefundService.new(order).start! }

  describe '#full_refundable_by_admin?' do
    context 'when order pending' do
      let(:order) { create(:order) }

      specify { expect { order_full_refund }.to raise_error(OrderFullRefundService::NotFullRefundableError) }
    end

    context 'when order with long_term_cancelled_at' do
      let(:order) { create(:order, :active, :long_term_cancelled_at) }

      specify { expect { order_full_refund }.to raise_error(OrderFullRefundService::NotFullRefundableError) }
    end
  end

  describe '#last_payment_completed?' do
    context 'when last payment success' do
      let(:order) { create(:order, :with_payments) }

      it { expect { order_full_refund }.to change(order, :status).from('active').to('full_refunded') }
    end

    context 'when last payment resolved' do
      let(:order) { create(:order, :with_resolved_payments) }

      it { expect { order_full_refund }.to change(order, :status).from('active').to('full_refunded') }
    end

    context 'when last payment retry' do
      let(:order) { create(:order, :with_payments) }

      specify do
        create(:payment, :retry, order: order)

        expect { order_full_refund }.to raise_error(OrderFullRefundService::PaymentUncompletedError)
        expect(order.payments.first.status).to eq('success')
        expect(order.last_payment.status).to eq('retry')
        expect(order.payments.count).to eq(2)
      end
    end

    context 'when last payment failed' do
      let(:order) { create(:order, :with_payments) }

      specify do
        create(:payment, :fail, order: order)

        expect { order_full_refund }.to raise_error(OrderFullRefundService::PaymentUncompletedError)
        expect(order.payments.first.status).to eq('success')
        expect(order.last_payment.status).to eq('failed')
        expect(order.payments.count).to eq(2)
      end
    end
  end
end
