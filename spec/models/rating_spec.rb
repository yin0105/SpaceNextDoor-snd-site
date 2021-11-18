# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rating, type: :model do
  subject { create(:rating, order: @order) }

  before(:all) do
    @space = create(:space, :activated, :two_years)
    @order = create(:order, space: @space)
  end

  it { is_expected.to belong_to(:order) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:ratable) }

  describe 'lifecycles' do
    describe 'after create' do
      it 'correct rater_type' do
        expect(subject.rater_type).not_to eq(nil)
      end

      it 'incorrect rater_type' do
        subject.rater_type = :user
        expect(subject).not_to be_valid
      end
    end

    describe 'after being rated' do
      it 'status is completed' do
        subject.update(rate: 5.0)
        expect(subject.reload).to be_completed
      end
    end
  end
end
