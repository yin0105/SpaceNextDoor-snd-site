# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Space::AsCreateStep3, type: :model do
  it { is_expected.to validate_presence_of(:minimum_rent_days) }
end
