# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'HostContactsController', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET #show' do
    it 'http status success' do
      get host_contact_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'http status success' do
      get new_host_contact_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:model_scope) { Contact::Host }

    def create_host_contact(data = {})
      hash = attributes_for(:contact).slice(:name, :phone, :email)
      post host_contact_path, params: { contact: hash.merge(data) }
    end

    context 'create host contact success' do
      it 'create a host contact' do
        expect(user.as_host.contact).to be_nil
        expect { create_host_contact }.to change(model_scope, :count).by(1)
        expect(user.as_host.contact&.present?).to be_truthy
      end

      it 'update host contact' do
        data = { email: 'host@test.com' }
        create_host_contact
        create_host_contact(data)
        expect(user.as_host.contact.email).to eq(data[:email])
      end
    end
  end
end
