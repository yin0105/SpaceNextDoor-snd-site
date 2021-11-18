# frozen_string_literal: true

require 'rails_helper'

describe 'OrderEarlyEndServiceSpec' do
  subject(:order_early_end) { OrderEarlyEndService.new(order).start! }

  describe '#discounted_endable?' do
    context 'with one month discount' do
      let(:order) { create(:order, :with_payments, :with_valid_one_month_discount) }

      it 'terminate after discount required date' do
        order.update(long_term_cancelled_at: order.start_at + Order::DISCOUNT_ONE_MONTH_DAYS.days)

        expect { order_early_end }.to change(order, :status).from('active').to('early_ended')
      end

      specify do
        order.update(long_term_cancelled_at: order.start_at + (Order::DISCOUNT_ONE_MONTH_DAYS - 1).days)

        expect { order_early_end }.to raise_error(OrderEarlyEndService::NotOverDiscountRequiredDaysError)
      end
    end

    context 'with two month discount' do
      let(:order) { create(:order, :with_payments, :with_valid_two_months_discount) }

      it 'terminate after discount required date' do
        order.update(long_term_cancelled_at: order.start_at + Order::DISCOUNT_TWO_MONTHS_DAYS)

        expect { order_early_end }.to change(order, :status).from('active').to('early_ended')
      end

      specify do
        order.update(long_term_cancelled_at: order.start_at + (Order::DISCOUNT_TWO_MONTHS_DAYS - 1).days)

        expect { order_early_end }.to raise_error(OrderEarlyEndService::NotOverDiscountRequiredDaysError)
      end
    end

    context 'with six month discount' do
      let(:order) { create(:order, :with_payments, :with_valid_six_months_discount) }

      it 'terminate after discount required date' do
        order.update(long_term_cancelled_at: order.start_at + Order::DISCOUNT_SIX_MONTHS_DAYS)

        expect { order_early_end }.to change(order, :status).from('active').to('early_ended')
      end

      specify do
        order.update(long_term_cancelled_at: order.start_at + (Order::DISCOUNT_SIX_MONTHS_DAYS - 1).days)

        expect { order_early_end }.to raise_error(OrderEarlyEndService::NotOverDiscountRequiredDaysError)
      end
    end
  end

  describe '#last_payment_completed?' do
    context 'when last payment success' do
      let(:order) { create(:order, :with_payments) }

      it 'can early ended' do
        order.update(long_term_cancelled_at: order.start_at + 29.days)

        expect { order_early_end }.to change(order, :status).from('active').to('early_ended')
        expect(order.payments.count).to eq(1)
      end
    end

    context 'when last payment resolved' do
      let(:order) { create(:order, :with_resolved_payments) }

      it 'can early ended' do
        order.update(long_term_cancelled_at: order.start_at + 29.days)

        expect { order_early_end }.to change(order, :status).from('active').to('early_ended')
        expect(order.payments.count).to eq(1)
      end
    end

    context 'when last payment retry' do
      let(:order) { create(:order, :with_payments) }

      specify do
        order.update(long_term_cancelled_at: order.start_at + 59.days)
        create(:payment, :retry, order: order)

        expect { order_early_end }.to raise_error(OrderEarlyEndService::PaymentUncompletedError)
        expect(order.payments.first.status).to eq('success')
        expect(order.last_payment.status).to eq('retry')
      end
    end

    context 'when last payment failed' do
      let(:order) { create(:order, :with_payments) }

      specify do
        order.update(long_term_cancelled_at: order.start_at + 59.days)
        create(:payment, :fail, order: order)

        expect { order_early_end }.to raise_error(OrderEarlyEndService::PaymentUncompletedError)
        expect(order.payments.first.status).to eq('success')
        expect(order.last_payment.status).to eq('failed')
      end
    end
  end

  describe '#long_lease_transformed_terminallable?' do
    context 'with order transformed' do
      let(:order) { create(:order, :with_payments, end_at: Time.zone.today + 28.days) }

      before do
        allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1)

        TransformLongLeaseService.new(order, 'admin').start!
      end

      it 'terminate after short term period' do
        order.update(long_term_cancelled_at: order.long_term_start_at)

        expect { order_early_end }.to change(order, :status).from('active').to('early_ended')
      end

      specify do
        order.update(long_term_cancelled_at: order.long_term_start_at - 1.day)

        expect { order_early_end }.to raise_error(OrderEarlyEndService::ShortTermEarlyEndError)
      end
    end
  end
end
