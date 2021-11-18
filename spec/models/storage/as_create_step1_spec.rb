# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::AsCreateStep1, type: :model do
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:features) }
  it { is_expected.to have_one(:space).class_name('Space::AsCreateStep1').dependent(:destroy) }
end
