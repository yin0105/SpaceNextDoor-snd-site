# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Spaces', type: :feature do
  describe 'date inputs' do
    it 'enable' do
      visit spaces_path

      expect(find('.search_check_in input')[:disabled]&.to_sym).not_to eq(true)
      expect(find('.search_check_out input')[:disabled]&.to_sym).not_to eq(true)
    end
  end
end
