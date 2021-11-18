# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::AsCreateStep3, type: :model do
  it { is_expected.to validate_presence_of(:checkin_time) }
  it { is_expected.to have_one(:space).class_name('Space::AsCreateStep3').dependent(:destroy) }
end
