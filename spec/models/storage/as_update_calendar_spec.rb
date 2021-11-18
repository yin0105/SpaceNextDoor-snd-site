# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::AsUpdateCalendar, type: :model do
  it { is_expected.to have_one(:space).class_name('Space::AsUpdateCalendar').dependent(:destroy) }
end
