# frozen_string_literal: true

require 'rails_helper'

describe 'CreatePaymentService' do
  subject { order.down_payment.status }

  before { allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1) }

  let(:order) { create(:order) }

  before { CreatePaymentService.new(order).start! }

  it { is_expected.to eq('success') }

  context 'long term long term cancelled at exist' do
    subject { order.payments.last.status }

    let(:order) { create(:order, long_term_cancelled_at: Time.zone.today) }

    it { is_expected.to eq('aborted') }
  end
end
