# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    allow(User).to receive(:from_omniauth).and_return(build(:user))
  end

  describe 'GET #facebook' do
    def facebook
      get :facebook
    end

    context 'with valid auth' do
      before { allow_any_instance_of(User).to receive(:persisted?).and_return(true) }

      it 'have current_user' do
        facebook
        expect(controller.current_user).not_to be_nil
      end
    end

    context 'with invalid auth' do
      before { allow_any_instance_of(User).to receive(:persisted?).and_return(false) }

      it 'have no current_user' do
        facebook
        expect(controller.current_user).to be_nil
      end

      it 'redirect to new_user_registration_path' do
        facebook
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
