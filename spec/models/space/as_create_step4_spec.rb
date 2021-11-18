# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Space::AsCreateStep4, type: :model do
  it { is_expected.to monetize(:daily_price) }
end
