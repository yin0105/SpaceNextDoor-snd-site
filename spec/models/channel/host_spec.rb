# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Channel::Host, type: :model do
  describe '#target' do
    let(:channel) { create(:channel).becomes(described_class) }

    it 'return host' do
      expect(channel.target).to eq(channel.guest)
    end
  end
end
