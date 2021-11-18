# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::PreferredPhonesController, type: :controller do
  let(:user) { create(:user) }

  before { login(user) }

  describe 'GET #show' do
    subject { get :show }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template(:show) }
  end

  describe 'PATCH #update' do
    context 'when user#phone is blank' do
      subject(:update_preferred_phone) { patch :update, params: { user: { preferred_phone: phone } } }

      let(:phone) { '+65 6353 9325' }

      it { expect { update_preferred_phone }.not_to(change { user.reload.preferred_phone }) }
      it { is_expected.to render_template(:show) }
    end

    context 'when user#phone is present' do
      let(:user) { create(:user, :with_phone) }

      context 'with valid preferred_phone' do
        subject(:update_preferred_phone) { patch :update, params: { user: { preferred_phone: phone } } }

        let(:phone) { '+65 6353 9325' }

        it { expect { update_preferred_phone }.to(change { user.reload.preferred_phone }) }
        it { is_expected.to redirect_to preferred_phone_path }
      end

      context 'with invalid preferred_phone' do
        subject(:update_preferred_phone) { patch :update, params: { user: { preferred_phone: phone } } }

        let(:phone) { '+65 1234 5678' }

        it { expect { update_preferred_phone }.not_to(change { user.reload.preferred_phone }) }
        it { is_expected.to render_template(:show) }
      end
    end
  end
end
