# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DirectOrder, type: :model do
  subject { build(:direct_order, space: @space, term: true) }

  before(:all) { @space = create(:space, :two_years, :activated, minimum_rent_days: 2) }

  def date_after(total)
    total.days.from_now.to_date
  end

  it { is_expected.to validate_presence_of(:start_at) }
  it { is_expected.to validate_presence_of(:end_at) }
  it { is_expected.to validate_presence_of(:term) }

  describe 'before_validation callbacks' do
    describe '#prepare_order' do
      it 'has a host' do
        subject.host = nil
        expect(subject).to be_valid
      end

      it 'has a same price as space daily_price' do
        subject.price = nil
        expect(subject).to be_valid
      end
    end
  end

  describe 'validations' do
    describe '#validate_start_at_and_end_at' do
      it 'start_at needs be earlier than end_at' do
        subject.end_at = subject.start_at
        expect(subject).not_to be_valid
      end
    end

    describe '#validate_dates' do
      context 'check space dates' do
        let!(:dates) { (date_after(0)..date_after(30)).to_a }
        let!(:space) { build(:space, dates: dates) }

        it "dates selected should be included in space's dates" do
          subject.space = space
          subject.assign_attributes(
            start_at: date_after(0),
            end_at: date_after(40)
          )
          expect(subject).not_to be_valid
        end
      end

      context "check space's active orders dates" do
        let!(:order1) { create(:order, :active, space: @space, start_at: date_after(5), end_at: date_after(28)) }
        let!(:order2) { create(:order, :active, space: @space, start_at: date_after(29), end_at: date_after(57)) }

        it "fail, when dates aren't contained in space's available dates" do
          subject.assign_attributes(
            start_at: date_after(0),
            end_at: date_after(179)
          )
          expect(subject).not_to be_valid
        end

        it 'fail, when start date is not within 30-day range starting from the date placing order' do
          subject.assign_attributes(
            start_at: date_after(58),
            end_at: date_after(179)
          )
          expect(subject).not_to be_valid
        end

        it "success, when dates are contained in space's available dates" do
          subject.assign_attributes(
            start_at: date_after(0),
            end_at: date_after(4)
          )
          expect(subject).to be_valid
        end
      end
    end

    describe '#validate_minimum_rent_days' do
      it 'fail, when minimum rents days is bigger than days' do
        days = @space.minimum_rent_days - (@space.minimum_rent_days > 1 ? 2 : 1)

        subject.assign_attributes(
          start_at: date_after(0),
          end_at: date_after(days)
        )
        expect(subject).not_to be_valid
      end

      it 'success, when days is bigger than minimum rent days' do
        days = @space.minimum_rent_days

        subject.assign_attributes(
          start_at: date_after(0),
          end_at: date_after(days)
        )
        expect(subject).to be_valid
      end
    end

    describe '#validate_identity' do
      subject { build(:direct_order, space: @space, guest: @space.user.as_guest) }

      it 'invalid' do
        expect(subject).to be_invalid
      end
    end

    describe '#validate_phone' do
      subject { build(:direct_order, space: @space, guest: user.as_guest) }

      let(:user) { create(:user, :with_payment_method) }

      it 'invalid' do
        expect(subject).to be_invalid
      end
    end

    describe '#validate_payment_method' do
      subject { build(:direct_order, space: @space, guest: user.as_guest) }

      let(:user) { create(:user, :with_phone) }

      it 'invalid' do
        expect(subject).to be_invalid
      end
    end
  end

  describe 'before_create callbacks' do
    describe 'type and total_payment_cycle' do
      context 'days >= 30' do
        it 'type is instalment, total_payment_cycle is not 1' do
          subject.save
          expect(subject.type).to eq('instalment')
          expect(subject.total_payment_cycle).not_to eq(1)
        end
      end

      context 'days < 30' do
        it 'type is payoff, total_payment_cycle is 1' do
          subject.assign_attributes(start_at: date_after(0), end_at: date_after(28))
          subject.save
          expect(subject.type).to eq('payoff')
          expect(subject.total_payment_cycle).to eq(1)
        end
      end
    end

    describe 'remain_payment_cycle' do
      it 'is as same as total_payment_cycle' do
        expect(subject.remain_payment_cycle).to eq(subject.total_payment_cycle)
      end
    end

    describe 'service_fee' do
      it 'return default host rate' do
        subject.save
        expect(subject.service_fee.host_rate).to eq(Settings.service_fee.host_rate)
      end

      it 'return default guest rate' do
        subject.save
        expect(subject.service_fee.guest_rate).to eq(Settings.service_fee.guest_rate)
      end
    end
  end
end
