# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::AsCreateStep2, type: :model do
  it { is_expected.to have_one(:space).class_name('Space::AsCreateStep2').dependent(:destroy) }
end
