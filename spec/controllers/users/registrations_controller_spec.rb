# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Users::RegistrationsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'POST #create' do
    subject do
      hash = attributes_for(:user)
      post :create, params: { user: hash }
    end

    it 'creates a new user' do
      expect { subject }.to change(User, :count).by(1)
    end
  end

  describe 'PATCH #update' do
    subject do
      hash = { first_name: 'first name', last_name: 'last name' }
      patch :update, params: { user: hash }
    end

    let(:user) { create(:user) }

    before { login(user) }

    it 'update the user' do
      subject
      expect(user.reload.first_name).to eq('first name')
      expect(user.reload.last_name).to eq('last name')
    end
  end
end
