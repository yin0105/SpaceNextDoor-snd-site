# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'HasAddress' do
  it { is_expected.to have_one(:address) }
  it { is_expected.to accept_nested_attributes_for(:address) }
end
