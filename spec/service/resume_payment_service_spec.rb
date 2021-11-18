# frozen_string_literal: true

require 'rails_helper'

describe 'ResumePaymentService' do
  subject { order.payments.last.status }

  before { allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1) }

  let(:order) { create(:order, :with_failed_payments) }

  before { ResumePaymentService.new(order).start! }

  it { is_expected.to eq('resolved') }
end
