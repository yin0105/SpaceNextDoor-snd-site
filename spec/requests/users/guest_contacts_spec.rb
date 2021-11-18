# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GuestContactsController', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET #show' do
    it 'http status success' do
      get guest_contact_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'http status success' do
      get new_guest_contact_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:model_scope) { Contact::Guest }

    def create_guest_contact(data = {})
      hash = attributes_for(:contact).slice(:name, :phone, :email)
      post guest_contact_path, params: { contact: hash.merge(data) }
    end

    context 'create guest contact success' do
      it 'create a guest contact' do
        expect(user.as_guest.contact).to be_nil
        expect { create_guest_contact }.to change(model_scope, :count).by(1)
        expect(user.as_guest.contact&.present?).to be_truthy
      end

      it 'update guest contact' do
        data = { email: 'guest@test.com' }
        create_guest_contact
        create_guest_contact(data)
        expect(user.as_guest.contact.email).to eq(data[:email])
      end
    end
  end
end
