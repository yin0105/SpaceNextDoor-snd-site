# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingSlot, type: :model do
  it { is_expected.to belong_to(:space) }
  it { is_expected.to validate_uniqueness_of(:date).scoped_to(:space_id) }
end
