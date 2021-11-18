# frozen_string_literal: true

require 'rails_helper'

describe 'OrderRevokeService' do
  before { Order.aasm.state_machine.config.no_direct_assignment = false }

  let(:order) { create(:order) }

  describe 'revoke order failed' do
    subject { OrderRevokeService.new(order).start! }

    before { order.update(status: :active) }

    it { expect { subject }.to raise_error(OrderRevokeService::NotRevocableError) }
  end

  describe 'revoke order successfully' do
    before {  OrderRevokeService.new(order).start! }

    it 'order should be canceld' do
      expect(order.status).to eq('cancelled')
    end
  end
end
