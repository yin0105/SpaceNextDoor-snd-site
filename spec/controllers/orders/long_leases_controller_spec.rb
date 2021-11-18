# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orders::LongLeasesController, type: :controller do
  describe 'POST #destroy' do
    let(:order) { create(:order, :with_payments) }

    before { login(order.guest.as_user) }

    it "returns error if don't have termination date" do
      post :destroy, params: { order_id: order.id }
      expect(controller).to set_flash.now[:error]
    end

    context 'with correct terminate date' do
      let(:early_check_out) { Time.zone.today }

      before { post :destroy, params: { order_id: order.id, early_check_out: early_check_out } }

      it 'redirects back to orders' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
