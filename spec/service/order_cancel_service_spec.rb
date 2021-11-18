# frozen_string_literal: true

require 'rails_helper'

describe 'OrderCancelServiceSpec' do
  subject(:order_cancel) do
    order.update(long_term_cancelled_at: Time.zone.now)
    OrderCancelService.new(order).start!
  end

  describe '#cancellable_by_admin?' do
    context 'when order started already' do
      let(:order) { create(:order, :active) }

      specify { expect { order_cancel }.to raise_error(OrderCancelService::PrecancelError) }
    end

    context 'when order not yet started' do
      let(:order) { create(:order, :with_payments, start_at: Time.zone.today + 1.day) }

      it { expect { order_cancel }.to change(order, :status).from('active').to('cancelled') }
    end
  end

  describe '#last_payment_completed?' do
    context 'when down payment (is last payment too at the same time) failed' do
      let(:order) { create(:order, :with_failed_payments, start_at: Time.zone.today + 1.day) }

      specify { expect { order_cancel }.to raise_error(OrderCancelService::PaymentUncompletedError) }
    end

    context 'when down payment (is last payment too at the same time) success' do
      let(:order) { create(:order, :with_payments, start_at: Time.zone.today + 1.day) }

      it { expect { order_cancel }.to change(order, :status).from('active').to('cancelled') }
    end

    context 'when down payment (is last payment too at the same time) resolved' do
      let(:order) { create(:order, :with_resolved_payments, start_at: Time.zone.today + 1.day) }

      it { expect { order_cancel }.to change(order, :status).from('active').to('cancelled') }
    end
  end
end
