# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::AsSubmit, type: :model do
  describe 'callbacks' do
    describe 'before_validations' do
      before { create(:storage) }

      let(:storage) { described_class.last }

      it 'may submit' do
        allow_any_instance_of(Space).to receive(:may_submit?).and_return(true)
        expect_any_instance_of(Space).to receive(:may_submit?)
        storage.save
      end
    end
  end
end
