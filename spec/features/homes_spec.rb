# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :feature do
  it 'can access home page' do
    visit(root_path)
    expect(page).to have_current_path(root_path)
  end
end
