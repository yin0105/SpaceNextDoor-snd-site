# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ActionLog, type: :model do
  it { is_expected.to validate_presence_of(:admin) }
  it { is_expected.to validate_presence_of(:target_id) }
  it { is_expected.to validate_presence_of(:target_type) }
  it { is_expected.to validate_presence_of(:event) }
  it { is_expected.to validate_presence_of(:status) }
end
