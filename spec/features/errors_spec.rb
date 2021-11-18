# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Errors', type: :feature do
  describe 'request not exist routes' do
    it 'GET data not found' do
      visit '/spaces/396/favorite'
      expect(page).to have_content('This Page Not Found')
    end

    it 'GET specific file is not exist' do
      visit '/random.js'
      expect(page).to have_content('File not found')
    end
  end
end
