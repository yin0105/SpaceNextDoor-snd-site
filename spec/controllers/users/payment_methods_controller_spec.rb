# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::PaymentMethodsController, type: :controller do
  let(:user) { create(:user) }

  before { login(user) }

  describe 'GET #show' do
    it 'http status success' do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'http status success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:model_scope) { User::PaymentMethod }

    def create_payment_method
      hash = attributes_for(:payment_method).slice(:token, :identifier, :expiry_date)
      post :create, params: hash
    end

    context 'stripe response success' do
      before { allow(Stripe::Customer).to receive(:create).with(an_instance_of(Hash)).and_return('id' => '11111111') }

      it 'create a payment method' do
        expect { create_payment_method }.to change(model_scope, :count).by(1)
        expect(assigns[:payment_method].expiry_date).not_to be_nil
        expect(assigns[:payment_method].identifier).not_to be_nil
        expect(assigns[:payment_method].token).not_to be_nil
      end

      it 'reponse success redirect path' do
        create_payment_method
        expect(response.body).to eq({ path: payment_method_path }.to_json)
      end
    end

    context 'stripe response failure' do
      before { allow(Stripe::Customer).to receive(:create) { raise Stripe::InvalidRequestError.new('', {}) } }

      it 'redirect to new_payment_method_path' do
        bypass_rescue
        expect { create_payment_method }.to raise_error(Stripe::InvalidRequestError)
      end

      it 'reponse failure redirect path' do
        create_payment_method
        bypass_rescue
        expect(response.body).to eq({ path: new_payment_method_path }.to_json)
      end
    end
  end
end
