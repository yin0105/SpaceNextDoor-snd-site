# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Space::AsCreateStep1, type: :model do
  it { is_expected.to validate_presence_of(:property) }
end