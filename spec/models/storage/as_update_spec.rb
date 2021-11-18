# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::AsUpdate, type: :model do
  it { is_expected.to validate_presence_of(:checkin_time) }
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.not_to allow_value([]).for(:features) }
end
