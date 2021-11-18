# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spaces::ShelvesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:space) { FactoryBot.create(:space, :activated, user: user) }
  let(:deactivated_space) { FactoryBot.create(:space, :deactivated, user: user) }

  before { login(user) }

  describe 'POST /spaces/:id/shelf' do
    it 'can change status to activated' do
      post :create, params: { space_id: deactivated_space.id }
      expect(response).to redirect_to(user_spaces_path)
    end
  end

  describe 'DELETE /spaces/:id/shelf' do
    it 'can change status to deactivated' do
      post :destroy, params: { space_id: space.id }
      expect(response).to redirect_to(user_spaces_path)
    end
  end
end
