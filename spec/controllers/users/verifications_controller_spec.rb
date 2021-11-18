# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::VerificationsController, type: :controller do
  let(:user) { create(:user) }

  before { login(user) }

  describe 'GET #show' do
    it 'return a User::VerificationForm' do
      get :show
      expect(assigns[:user]).to be_a(User::VerificationForm)
    end
  end

  describe 'POST #create' do
    before { allow(SmsService).to receive(:new).and_return(double(SmsService, send_out: true)) }

    def create_phone
      hash = { phone: '89999999' }
      post :create, params: { user: hash }
    end

    context 'create succeed' do
      it 'create a verification code' do
        expect { create_phone }.to change(VerificationCode, :count).by(1)
      end

      it 'redirect to' do
        create_phone
        expect(response).to redirect_to(verification_path)
      end
    end

    context 'create fail' do
      before { allow_any_instance_of(User::VerificationForm).to receive(:update).and_return(false) }

      it 'render :show template' do
        create_phone
        expect(response).to render_template(:show)
      end
    end
  end
end
