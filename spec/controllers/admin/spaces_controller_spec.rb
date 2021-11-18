# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SpacesController, type: :controller do
  let(:admin) { create(:admin) }
  let(:space) { create(:space, :pending) }

  before { login(admin) }

  describe 'GET edit_disapproval' do
    subject { get :edit_disapproval, params: { id: space.id } }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template(:disapprove) }
  end

  describe 'PATCH update_disapproval' do
    context 'when reasons present' do
      subject(:disapprove_space) do
        patch :update_disapproval, params: { id: space.id, space: { reasons_for_disapproval: Faker::Lorem } }
      end

      it { is_expected.to redirect_to(admin_spaces_path) }
      it { expect { disapprove_space }.to change { space.reload.status }.from('pending').to('disapproved') }
    end

    context 'when reasons blank' do
      subject(:disapprove_space) do
        patch :update_disapproval, params: { id: space.id, space: { reasons_for_disapproval: '' } }
      end

      it { is_expected.to render_template(:disapprove) }
      it { expect { disapprove_space }.not_to(change { space.reload.status }) }
    end
  end
end
