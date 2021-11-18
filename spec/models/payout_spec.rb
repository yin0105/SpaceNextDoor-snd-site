# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payout, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:payment) }
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to monetize(:amount) }

  describe 'is long term order cancelled' do
    subject { OrderCancelService.new(order).start! }

    let(:space) { create(:space, :activated, :two_years) }

    before do
      order.reload
    end

    describe 'order was canceled within a week' do
      let(:order) { create(:order, :will_start_in_7_days, :with_premium, :with_payments, space: space) }

      it 'amount equals cost of deposit plus premium' do
        refund_amount = order.last_payment.deposit + order.last_payment.premium

        subject
        expect(order.refunds.first.amount).to eq(refund_amount)
      end
    end

    describe 'order was canceled before a week ago' do
      let(:order) { create(:order, :will_start_between_8_and_14_days, :with_payments, space: space) }

      it 'amount equals cost of amount minus (rent times 0.5 plus guest_service_fee)' do
        refund_amount = order.last_payment.amount - (order.last_payment.rent * 0.5 + order.last_payment.guest_service_fee)

        subject
        expect(order.refunds.first.amount).to eq(refund_amount)
      end
    end

    describe 'order was canceled before two weeks ago' do
      let(:order) { create(:order, :will_start_after_14_days, :with_payments, space: space) }

      it 'amount equals cost of amount minus guest_service_fee' do
        refund_amount = order.last_payment.amount - order.last_payment.guest_service_fee

        subject
        expect(order.refunds.first.amount).to eq(refund_amount)
      end
    end
  end

  describe 'is long term order early ended' do
    subject { OrderEarlyEndService.new(order).start! }

    let(:space) { create(:space, :activated, :two_years) }

    context 'with refund' do
      before do
        order.reload
      end

      describe 'order was early end' do
        let(:order) { create(:order, :with_payments, :with_refund, space: space) }

        it 'creates one payout to guest' do
          expect { subject }.to change { order.refunds.count }.from(0).to(1)
        end

        it 'amount equals cost of days rented in last service cycle plus service fee' do
          rent = order.last_payment.rent - order.last_payment.days_rented * order.price
          service_fee = order.price * (Order::INTERVAL - order.last_payment.days_rented) * order.service_fee_guest_rate
          refund_amount = rent + service_fee

          subject
          expect(order.refunds.first.amount).to eq(refund_amount)
        end
      end
    end

    context 'without refund' do
      let(:order) { create(:order, :with_payments, :with_no_refund, space: space) }

      it 'creates no payout to guest' do
        expect { subject }.to change { order.reload.refunds.count }.by(0)
      end
    end
  end
end
