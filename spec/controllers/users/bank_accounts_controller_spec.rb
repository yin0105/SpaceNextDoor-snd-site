# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::BankAccountsController, type: :controller do
  let(:model_scope) { BankAccount }
  let(:user) { create(:user) }

  before { login(user) }

  describe 'GET #new' do
    def build_bank_account
      get :new
    end

    it 'returns http success' do
      build_bank_account
      expect(response).to have_http_status(:success)
    end

    it 'render a new bank account' do
      build_bank_account
      expect(assigns[:bank_account]).to be_a_new(model_scope)
    end
  end

  describe 'GET #show' do
    def show_bank_account
      get :show
    end

    context 'user has no account' do
      it 'returns http success' do
        show_bank_account
        expect(response).to have_http_status(:success)
      end
    end

    context 'user one account' do
      before { create(:bank_account, user: user) }

      it 'returns http success' do
        show_bank_account
        expect(response).to have_http_status(:success)
      end

      it 'assigns the bank_account' do
        show_bank_account
        expect(assigns(:bank_account)).not_to be_nil
        expect(assigns(:bank_account)).to be_a(model_scope)
        expect(assigns(:bank_account)).to eq(user.bank_account)
      end
    end
  end

  describe 'POST #create' do
    def create_bank_account(hash = {})
      attr = attributes_for(:bank_account)
      post :create, params: { bank_account: attr.merge(hash) }
    end

    context 'save succeed' do
      it 'redirects to bank_account_path' do
        create_bank_account
        expect(response).to redirect_to(bank_account_path)
      end

      it 'creates the bank account for the user' do
        expect(user.bank_account).to be_nil
        create_bank_account
        expect(user.reload.bank_account).not_to be_nil
      end
    end

    context 'save fail' do
      it 'redirects to bank_account_path' do
        allow_any_instance_of(model_scope).to receive(:save).and_return(false)
        create_bank_account
        expect(response).to render_template(:new)
      end
    end
  end
end
