# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::PaymentMethod, type: :model do
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to validate_presence_of(:expiry_date) }
  it { is_expected.to validate_presence_of(:identifier) }
  it { is_expected.to validate_presence_of(:token) }
end
