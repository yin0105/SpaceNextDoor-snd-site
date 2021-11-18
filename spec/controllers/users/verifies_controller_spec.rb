# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::VerifiesController, type: :controller do
  describe 'POST #create' do
    before do
      user = create(:user)
      login(user)

      allow(SmsService).to receive(:new).and_return(double(SmsService, send_out: true))
      @verification = create(:verification_code, user: user)
    end

    def create_verify(hash = {})
      attr = { format: 'json', type: 'phone', code: @verification.code }.merge(hash)
      post :create, params: attr
    end

    context 'succeed' do
      it 'redirect to verification_path' do
        create_verify
        expect(JSON.parse(response.body)['path']).to include(verification_path)
      end
    end

    context 'fail' do
      it 'render error json' do
        create_verify(code: 'wrongcode')
        expect(JSON.parse(response.body)['error']).to be_a(Hash)
      end
    end
  end
end
