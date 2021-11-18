# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::EmailsController, type: :controller do
  let(:user) { create(:user, :without_confirmation) }

  before { login(user) }

  describe 'POST #create' do
    before { @place = request.env['HTTP_REFERER'] = root_url }

    it 'resend confirmation instruction mail' do
      expect(DeviseBackgrounder).to receive(:confirmation_instructions).and_return(double(DeviseBackgrounder, deliver: true))
      post :create
    end

    it 'redirect to referer' do
      post :create
      expect(response).to redirect_to(@place)
    end
  end
end
