# frozen_string_literal: true

require 'rails_helper'

describe 'TransformLongLeaseService' do
  describe '#transformable_long_term?' do
    subject(:transformable) { TransformLongLeaseService.new(order, 'admin').transformable_long_term? }

    let(:space) { create(:space, :activated, :two_years) }

    context 'with long term false' do
      let(:order) { create(:order, :instalment, :with_payments, space: space) }

      it { is_expected.to be(false) }
    end

    context 'with pending status' do
      let(:order) { create(:order, :with_failed_payments, space: space) }

      it { is_expected.to be(false) }
    end

    context 'when service period not started yet' do
      let(:order) { create(:order, :with_payments, start_at: Time.zone.now + 1.day, space: space) }

      it { is_expected.to be(false) }
    end

    context 'when at service end date' do
      let(:order) { create(:order, :with_payments, start_at: Time.zone.now - 7.days, space: space) }

      it { is_expected.to be(false) }
    end
  end

  describe 'transform order to long term lease' do
    subject(:transform_long_lease) { TransformLongLeaseService.new(order, 'admin').start! }

    let(:order) { create(:order, :payoff, :with_payments, space: space) }

    context 'when available booking slots not enough' do
      let(:space) { create(:space, :activated, :one_month) }

      it { expect { transform_long_lease }.not_to change(order, :long_term) }
    end

    context 'when booked already by other order' do
      let(:space) { create(:space, :activated, :two_years) }

      before { create(:order, :with_payments, start_at: Time.zone.now + 29.days, space: space) }

      it { expect { transform_long_lease }.not_to change(order, :long_term) }
    end

    context 'when short term payment failed' do
      let(:space) { create(:space, :activated, :two_years) }
      let(:order) { create(:order, :payoff, :with_failed_payments, space: space) }

      before { allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1) }

      it { expect { transform_long_lease }.not_to change(order, :long_term) }
    end

    context 'when short term payment retry' do
      let(:space) { create(:space, :activated, :two_years) }
      let(:order) { create(:order, :payoff, :with_retry_payments, space: space) }

      before { allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1) }

      it { expect { transform_long_lease }.not_to change(order, :long_term) }
    end

    context 'when success' do
      before { allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1) }

      let(:space) { create(:space, :activated, :two_years) }
      let(:order) { create(:order, :payoff, :with_payments, space: space) }

      def order_schedules(order)
        order.schedules.scheduled.where(event: %i[end before_end]).present?
      end

      def payment_count(order)
        order.payments.count
      end

      def next_payment_schedule(order)
        date = order.schedules.scheduled.where(event: :payment).first&.schedule_at&.to_date
        count = order.schedules.scheduled.where(event: :payment).count
        { date: date, count: count }
      end

      it { expect { transform_long_lease }.to change(order, :long_term).from(false).to(true) }
      it { expect { transform_long_lease }.to change(order, :long_term_start_at).from(nil).to(order.end_at + 1.day) }
      it { expect { transform_long_lease }.to change(order, :end_at).from(order.end_at).to(order.end_at + Order::INTERVAL * 3) }
      it { expect { transform_long_lease }.to change(order, :total_payment_cycle).from(1).to(4) }
      it { expect { transform_long_lease }.to change(order, :remain_payment_cycle).from(0).to(2) }
      it { expect { transform_long_lease }.to change { order_schedules(order) }.from(true).to(false) }
      it { expect { transform_long_lease }.to change { payment_count(order) }.from(1).to(2) }

      it 'next payment schedule' do
        transform_long_lease

        expect(next_payment_schedule(order)[:date]).to eq(order.long_term_start_at + 15.days)
        expect(next_payment_schedule(order)[:count]).to eq(1)
      end
    end
  end
end
