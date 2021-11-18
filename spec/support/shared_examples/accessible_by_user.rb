# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'accessible by user' do
  let(:user) { create(:user) }

  context "user didn't login" do
    it 'redirects to root page' do
      visit url
      expect(page).to have_current_path(root_path)
    end
  end

  context 'user login' do
    it 'success, when being logined' do
      sign_in(user)
      visit url
      expect(page.status_code).to eq(200)
    end
  end
end
