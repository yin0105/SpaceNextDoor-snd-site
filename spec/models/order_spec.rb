# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  subject { create(:order, space: @space) }

  before { described_class.aasm.state_machine.config.no_direct_assignment = false }

  before(:all) { @space = create(:space, :activated, :two_years) }

  describe 'model' do
    it { is_expected.to have_one(:down_payment) }
    it { is_expected.to have_one(:last_payment) }
    it { is_expected.to have_one(:service_fee) }
    it { is_expected.to belong_to(:guest) }
    it { is_expected.to belong_to(:host) }
    it { is_expected.to belong_to(:space) }
    it { is_expected.to belong_to(:channel) }
    it { is_expected.to monetize(:price) }
    it { is_expected.to monetize(:premium) }
  end

  describe 'life_cycle callbacks' do
    it 'does not change price after created' do
      space = create(:space, :activated, :two_years, daily_price: 1.to_money)
      order = create(:order, space: space)
      space.update(daily_price: 2.to_money)
      expect { order.save! }.not_to(change { order.price })
    end

    describe '#activate!' do
      it 'create a channel between guest and host given specific space' do
        expect(subject.channel).to be_nil
        subject.activate!
        expect(subject.channel).not_to be_nil
        expect(subject.channel.host).to eq(subject.host)
        expect(subject.channel.guest).to eq(subject.guest)
        expect(subject.channel.space).to eq(subject.space)
      end

      it 'if another user make an order for the same space' do
        subject.activate!
        order = create(:order, :active, space: @space, guest: create(:guest))
        expect(order.channel).not_to eq(@channel)
      end

      it 'mark booking_slots as booked - orders under 30 days' do
        order = create(:order, :active, space: @space, guest: create(:guest), start_at: Time.zone.today, end_at: Time.zone.today + 28.days)
        slots = order.space.booking_slots
        expect(slots.booked.count).to eq((order.start_at..order.end_at).count)
      end

      it 'mark booking_slots as booked - orders more than 30 days' do
        order = create(:order, :active, space: @space, guest: create(:guest), start_at: Time.zone.today, end_at: Time.zone.today + 29.days)
        slots = order.space.booking_slots
        expect(slots.booked.count).to eq(slots.where(date: order.start_at..(order.start_at + Order::LONGEST_YEAR.years - 1)).count)
      end

      context 'notify sombody' do
        before { allow(OrdersMailer).to receive(:activating).and_return(double(deliver_later: true)) }

        it 'notify landlord' do
          expect(subject).to receive(:notify_after_activate).at_least(:once)
          subject.activate!
        end
      end

      it 'create a message when no message in channel' do
        allow_any_instance_of(Message.const_get(:ActiveRecord_Associations_CollectionProxy)).to receive(:any?).and_return(false)
        expect_any_instance_of(Channel).to receive(:create_system_message).at_least(:once)
        subject.activate!
      end
    end

    context 'event complete' do
      before { subject.update(status: :active) }

      it 'create ratings for guest' do
        subject.complete!
        expect(subject.guest.ratings).not_to be_nil
        expect(subject.guest.ratings.count).to eq(2)
      end

      it 'create rating for host' do
        subject.complete!
        expect(subject.host.ratings).not_to be_nil
        expect(subject.host.ratings.count).to eq(1)
      end

      describe 'notify somebody' do
        before do
          allow(RatingsMailer).to receive(:host).and_return(double(deliver_later: true))
          allow(RatingsMailer).to receive(:guest).and_return(double(deliver_later: true))
        end

        it 'notify host' do
          expect(RatingsMailer).to receive(:host).at_least(:once)
          subject.complete!
        end

        it 'notify guest' do
          expect(RatingsMailer).to receive(:guest).at_least(:once)
          subject.complete!
        end
      end
    end

    context 'event cancel' do
      subject { create(:order, :with_payments, space: @space, start_at: Time.zone.today + 5, end_at: 10.days.from_now.to_date) }

      before { allow_any_instance_of(Accounting::OrderCancelService).to receive(:start).and_return(true) }

      it 'column cancelled_at is not nil' do
        subject.cancel!
        expect(subject.cancelled_at).not_to be_nil
      end

      it 'double entry for cancelling' do
        expect_any_instance_of(Accounting::OrderCancelService).to receive(:start)
        subject.cancel!
      end

      it 'refund payout for last payment' do
        subject.cancel!
        expect(subject.last_payment.payouts.refund).not_to be_empty
      end

      it 'booked booking_slots become available' do
        booking_dates = subject.space.dates
        subject.cancel!
        expect(subject.space.available_dates).to include(*booking_dates)
      end
    end

    context 'event review' do
      subject { create(:order, :with_payments, :completed, space: @space, start_at: Time.zone.today, end_at: 1.day.from_now.to_date) }

      before { allow_any_instance_of(Accounting::OrderReviewService).to receive(:start).and_return(true) }

      it 'double entry for reviewing' do
        expect_any_instance_of(Accounting::OrderReviewService).to receive(:start)
        subject.review!
      end

      it 'deposit and damage payout for last payment' do
        subject.review!
        expect(subject.last_payment.payouts.damage).not_to be_empty
        expect(subject.last_payment.payouts.deposit).not_to be_empty
      end
    end

    context 'event revoke' do
      it 'status change to :cancelled from pending' do
        subject.revoke!
        expect(subject).to be_cancelled
      end
    end
  end

  describe '#current_payment_cycle' do
    it 'equals total payment cycle when finished' do
      allow(subject).to receive(:remain_payment_cycle).and_return(0)
      expect(subject.current_payment_cycle).to eq(subject.total_payment_cycle)
    end
  end

  describe '#next_service_start_at' do
    it 'will increment by interval' do
      subject.remain_payment_cycle -= 1
      expect(subject.next_service_start_at).to eq(subject.start_at.beginning_of_day + Order::INTERVAL.days)
    end

    it 'will stop increment after order end at' do
      subject.remain_payment_cycle = 0
      expect(subject.next_service_start_at).to eq(subject.end_at.end_of_day)
    end
  end

  describe '#next_service_end_at' do
    it 'has same peroid with interval' do
      peroid = (subject.next_service_end_at - subject.next_service_start_at).to_i
      expect(peroid).to eq(Order::INTERVAL * 86_400 - 1)
    end

    it 'same as order end at' do
      subject.remain_payment_cycle = 1
      expect(subject.next_service_end_at).to eq(subject.end_at.end_of_day)
    end
  end

  describe '#next_service_days' do
    context 'more than 30 days left' do
      it 'equals one interval size' do
        expect(subject.next_service_days).to eq(Order::INTERVAL)
      end
    end

    context 'no more than 30 days left' do
      subject { build(:order, start_at: Time.zone.today, end_at: Time.zone.today + 6.days, space: @space) }

      it 'return remain days' do
        expect(subject.next_service_days).to eq(7)
      end
    end

    context 'payoff' do
      subject { build(:order, :payoff, space: @space) }

      it 'when subscription_type is payoff, return the orders.days' do
        expect(subject.next_service_days).to eq(subject.days)
      end
    end
  end

  describe '#insurance_enable' do
    context 'space insurance disable' do
      subject { create(:order, space: @space_without_insurance) }

      before do
        @space_without_insurance = create(:space, :activated, :default_insurance_disable_property)
      end

      it 'order insurance will be disable' do
        expect(subject.insurance_enable).to eq(false)
      end
    end

    context 'space insurance enable' do
      subject { create(:order, space: @space_with_insurance) }

      before do
        @space_with_insurance = create(:space, :activated, :default_insurance_enable_property)
      end

      it 'order insurance will be enable' do
        expect(subject.insurance_enable).to eq(true)
      end
    end
  end

  describe '#days' do
    subject { build(:order, space: @space) }

    it 'return # of days' do
      days = (subject.end_at - subject.start_at).to_i + 1
      expect(subject.days).to eq(days)
    end
  end

  describe '#receive_all_ratings?' do
    context "if order's ratings are already completed" do
      subject { create(:order, :completed, :rated, space: @space) }

      it 'return true ' do
        expect(subject).to be_receive_all_ratings
      end
    end

    context "if order's ratings doesn't exist" do
      it 'return false' do
        expect(subject).not_to be_receive_all_ratings
      end
    end

    context "if order's ratings are not completed" do
      subject { create(:order, :completed, space: @space) }

      it 'return false' do
        expect(subject).not_to be_receive_all_ratings
      end
    end
  end

  describe '#service_fee_host_rate, #service_fee_guest_rate' do
    it 'return default host rate' do
      expect(subject.service_fee_host_rate).to eq(subject.service_fee.host_rate)
    end

    it 'return default guest rate' do
      expect(subject.service_fee_guest_rate).to eq(subject.service_fee.guest_rate)
    end
  end

  describe '#remain_deposit' do
    self.use_transactional_tests = false

    context 'order has been paid' do
      subject { create(:order, :with_payments) }

      it 'return remaining deposit' do
        expect(subject.remain_deposit).to eq(subject.payments.first.deposit - subject.damage_fee)
      end
    end

    context "order hasn't been paid" do
      subject { create(:order) }

      it 'raise error when no payment exist' do
        expect(subject.remain_deposit).to eq(nil)
      end
    end
  end

  describe 'discount order needed days' do
    context 'when one_month discount' do
      subject { build(:order, :with_one_month_discount) }

      it 'rent days < 90 should not be save successfully' do
        @order = subject
        @order.end_at = @order.start_at + Faker::Number.between(from: 1, to: 88).days
        expect(@order.save).to be_falsy
      end

      it 'rent days >= 90 days should be save successfully' do
        @order = subject
        @order.end_at = @order.start_at + Faker::Number.between(from: 89, to: 364).days
        expect(@order.save).to be_truthy
      end
    end

    context 'when two_months discount' do
      subject { build(:order, :with_two_months_discount) }

      it 'rent days < 180 days should not be save successfully' do
        @order = subject
        @order.end_at = @order.start_at + Faker::Number.between(from: 1, to: 178).days
        expect(@order.save).to be_falsy
      end

      it 'rent days >= 180 days should be save successfully' do
        @order = subject
        @order.end_at = @order.start_at + Faker::Number.between(from: 179, to: 364)
        expect(@order.save).to be_truthy
      end
    end

    context 'when six_months discount' do
      let(:order_upto_179_days) { build(:order, :with_valid_six_months_discount, :rent_upto_179_days) }
      let(:order_more_then_180_days) { build(:order, :with_valid_six_months_discount, :rent_more_then_180_days) }

      it 'rent days < 180 days should not be save successfully' do
        expect(order_upto_179_days.save).to be_falsy
      end

      it 'rent days >= 180 days should be save successfully' do
        expect(order_more_then_180_days.save).to be_truthy
      end
    end
  end

  describe 'discount order early_endable' do
    context 'when one_month discount order' do
      subject { create(:order, :with_valid_one_month_discount) }

      it 'early_end_at less than 90 days should not be endable successfully' do
        @order = subject
        @params = {}
        @params[:early_check_out] = @order.start_at + Faker::Number.between(from: 1, to: 88).days
        expect(OrderDiscountEarlyEndableService.new(@order, @params)).not_to be_endable
      end

      it 'early_end_at over 90 days should be endable successfully' do
        @order = subject
        @params = {}
        @params[:early_check_out] = @order.start_at + Faker::Number.between(from: 89, to: 364).days
        expect(OrderDiscountEarlyEndableService.new(@order, @params)).to be_endable
      end
    end

    context 'when two_months discount order' do
      subject { create(:order, :with_valid_two_months_discount) }

      it 'early_end_at less than 180 days should not be endable successfully' do
        @order = subject
        @params = {}
        @params[:early_check_out] = @order.start_at + Faker::Number.between(from: 1, to: 178).days
        expect(OrderDiscountEarlyEndableService.new(@order, @params)).not_to be_endable
      end

      it 'early_end_at over 180 days should be endable successfully' do
        @order = subject
        @params = {}
        @params[:early_check_out] = @order.start_at + Faker::Number.between(from: 179, to: 364).days
        expect(OrderDiscountEarlyEndableService.new(@order, @params)).to be_endable
      end
    end

    context 'when six_months discount order' do
      subject { create(:order, :with_valid_six_months_discount) }

      it 'early_end_at less than 180 days should not be endable successfully' do
        @order = subject
        @params = {}
        @params[:early_check_out] = @order.start_at + Faker::Number.between(from: 1, to: 178).days
        expect(OrderDiscountEarlyEndableService.new(@order, @params)).not_to be_endable
      end

      it 'early_end_at over 180 days should be endable successfully' do
        @order = subject
        @params = {}
        @params[:early_check_out] = @order.start_at + Faker::Number.between(from: 179, to: 364).days
        expect(OrderDiscountEarlyEndableService.new(@order, @params)).to be_endable
      end
    end
  end
end
