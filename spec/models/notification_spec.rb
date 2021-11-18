# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  subject { create(:notification) }

  it { is_expected.to belong_to(:admin) }
  it { is_expected.to allow_value('').for(:title) }
  it { is_expected.to validate_presence_of(:content) }
end
