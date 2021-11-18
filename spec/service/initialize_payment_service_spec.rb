# frozen_string_literal: true

require 'rails_helper'

describe 'InitializePaymentService' do
  subject { InitializePaymentService.new(order).start! }

  let(:order) { create(:order) }

  context 'when initialize with a valid order' do
    it 'returns a valid payment' do
      expect(subject).to be_valid
    end
  end

  context 'when user payment method is nil' do
    let(:user) { create(:user) }
    let(:order) { create(:order, guest: user.as_guest) }

    it 'raises InvalidPaymentMethodError' do
      expect { subject }.to raise_error(InitializePaymentService::InvalidPaymentMethodError)
    end
  end

  context 'apply discount when order with one month discount' do
    let(:order) { create(:order, :with_valid_one_month_discount) }

    it 'first month payment amount should be discounted and equal to deposit' do
      expect(subject.amount).to eq(subject.deposit)
    end

    it 'after first month payment should not be discount' do
      Faker::Number.between(from: 1, to: 10).times { create(:payment, :success, order: order, user: order.guest.as_user) }
      expect(subject.amount).to be > 0
    end
  end

  context 'apply discount when order with two months discount' do
    let(:order)  { create(:order, :with_valid_two_months_discount) }

    it 'first month payment should be discounted and equal to deposit' do
      expect(subject.amount).to eq(subject.deposit)
    end

    it 'sixth month payment should be discount to free' do
      create_list(:payment, 5, :success, order: order, user: order.guest.as_user)
      expect(subject.amount).to be == 0
    end

    it 'between second month and fifth month payment should not be discounted' do
      Faker::Number.between(from: 1, to: 4).times { create(:payment, :success, order: order, user: order.guest.as_user) }
      expect(subject.amount).to be > 0
    end

    it 'after sixth month payment should not be discounted' do
      Faker::Number.between(from: 6, to: 12).times { create(:payment, :success, order: order, user: order.guest.as_user) }
      expect(subject.amount).to be > 0
    end
  end

  context 'apply discount when order with 6 months discount' do
    let(:order) { create(:order, :with_valid_six_months_discount) }

    it 'every payment should be 50% of amount' do
      expect(subject.rent).to eq((order.price / 2) * order.next_service_days)
    end

    it 'discount is not applied after 6 months' do
      create_list(:payment, 7, :success, order: order, user: order.guest.as_user)
      expect(subject.rent).to eq(order.price * order.next_service_days)
    end
  end

  context 'assign payment attributes' do
    it 'serial' do
      expect(subject.serial).to eq(order.payments.size)
    end

    it 'user' do
      expect(subject.user).to eq(order.guest)
    end

    it 'type' do
      expect(subject.payment_type).to eq(order.guest.payment_method.type)
    end

    it 'payment_method_identifier' do
      expect(subject.identifier).to eq(order.guest.payment_method.identifier)
    end

    it 'deposit' do
      expect(subject.deposit).to eq(order.price * Settings.deposit.days)
    end

    it 'service_fee' do
      host_service_fee = subject.rent * order.service_fee_host_rate
      guest_service_fee = subject.rent * order.service_fee_guest_rate
      expect([subject.host_service_fee, subject.guest_service_fee]).to eq([host_service_fee, guest_service_fee])
    end

    it 'rent' do
      expect(subject.rent).to eq(order.price * order.next_service_days)
    end

    it 'next service period' do
      expect([subject.service_start_at, subject.service_end_at]).to eq([order.next_service_start_at, order.next_service_end_at])
    end

    it 'last long lease payment service period' do
      order.update(long_term_cancelled_at: order.next_service_start_at + rand(1..28).days)
      expect([subject.service_start_at, subject.service_end_at]).to eq([order.next_service_start_at, order.long_term_cancelled_at.end_of_day])
    end

    it 'premium' do
      expect(subject.premium).to eq(order.premium)
    end
  end

  context 'when order with insurance' do
    context 'assign payment attributes' do
      let(:order) { create(:order, :with_premium) }

      it 'premium' do
        expect(subject.premium).to eq(order.premium)
      end
    end

    context 'apply discount when order with one month discount' do
      let(:order) { create(:order, :with_valid_one_month_discount, :with_premium) }

      it 'first month payment amount should be discounted and equal to deposit' do
        expect(subject.amount).to eq(subject.deposit + subject.premium)
      end
    end

    context 'apply discount when order with two months discount' do
      let(:order)  { create(:order, :with_valid_two_months_discount, :with_premium) }

      it 'first month payment should be discounted and equal to deposit' do
        expect(subject.amount).to eq(subject.deposit + subject.premium)
      end

      it 'sixth month payment should be discount to free' do
        create_list(:payment, 5, :success, order: order, user: order.guest.as_user)
        expect(subject.amount).to eq(subject.premium)
      end
    end
  end
end
