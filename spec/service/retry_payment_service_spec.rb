# frozen_string_literal: true

require 'rails_helper'

describe 'RetryPaymentService' do
  subject { order.payments.last.status }

  before { allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1) }

  let(:order) { create(:order, :with_retry_payments) }

  before { RetryPaymentService.new(order.payments.retry.last).start! }

  it { is_expected.to eq('success') }
end
