# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  before do
    described_class.aasm.state_machine.config.no_direct_assignment = false
  end

  let(:space) { create(:space, :activated, :two_years) }
  let(:order) { create(:order, space: space) }

  describe 'initialize' do
    subject(:payment) { create(:payment, order: order) }

    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to validate_presence_of(:payment_type) }
    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_presence_of(:service_start_at) }
    it { is_expected.to validate_presence_of(:service_end_at) }
    it { is_expected.to monetize(:rent) }
    it { is_expected.to monetize(:deposit) }
    it { is_expected.to monetize(:guest_service_fee) }
    it { is_expected.to monetize(:premium) }

    it { expect(payment.deposit).to eq(order.price * Settings.deposit.days) }
    it { expect(payment.serial).to eq(1) }
    it { expect(payment.guest_service_fee).to eq(payment.rent * Settings.service_fee.guest_rate) }
    it { expect(payment.host_service_fee).to eq(payment.rent * Settings.service_fee.host_rate) }
    it { expect(payment.premium).to eq(order.premium) }
    it { expect(payment.amount).to eq(payment.rent + payment.guest_service_fee + payment.deposit + payment.premium) }

    it "service_start_at shouldn't be ealier than order's start_at" do
      payment.service_start_at = order.start_at - 1.day
      expect(payment).not_to be_valid
    end

    it "service_end_at shouldn't be later than order's end_at" do
      payment.service_end_at = order.end_at + 1.day
      expect(payment).not_to be_valid
    end

    context 'with second period of order' do
      subject(:second_payment) { create(:payment, order: order) }

      before { create(:payment, order: order) }

      it { expect(second_payment.deposit).to eq(0.to_money) }
    end
  end

  describe '#succeed!' do
    # TODO: Validate remain_payment_cycle is updated
    subject(:payment_success) { create(:payment, :success_without_lock, order: order) }

    let(:space) { create(:space, :activated, :two_years) }
    let(:order) { create(:order, space: space) }
    let(:payment_service) { instance_double(Accounting::PaymentService) }

    before do
      allow(Accounting::PaymentService).to receive(:new).and_return(payment_service)
      allow(payment_service).to receive(:start)
    end

    describe '#schedule next payment' do
      it 'next_payment_day is 15 days after order.start_at' do
        schedule = payment_success.order.schedules.find_by(schedulable_type: :Order, event: :payment)
        next_service_start_at = (payment_success.order.start_at + Settings.order.days_to_next_service_end.days + 1.day).end_of_day
        expect(schedule.schedule_at.to_i).to eq(next_service_start_at.to_i)
      end
    end

    describe '#start accounting' do
      it 'call start_accounting' do
        expect(payment_service).to receive(:start).at_least(:once)
        payment_success
      end

      it 'schedule at service_start_at' do
        schedule = payment_success.schedules.find_by(schedulable_type: :Payment, event: :service_start)
        expect(schedule.schedule_at.to_i).to eq(payment_success.service_start_at.to_i)
      end
    end

    describe '#send notification' do
      subject(:payment_success) { payment.succeed! }

      let(:payment) { create(:payment, order: order) }

      it 'call #send_notification' do
        expect(payment).to receive(:send_notification).at_least(:once)
        payment_success
      end
    end

    describe '#schedule rent payout' do
      context 'with ten days rent payout type' do
        let(:order) { create(:order, :with_ten_days_rent_payout_type) }

        it 'schedule on the service_start_at + 8 days' do
          schedule = payment_success.schedules.where(schedulable_type: :Payment, event: :rent_payout).order(id: :asc).first
          expect(schedule.schedule_at.to_date).to eq(payment_success.service_start_at.to_date + 8.days)
        end

        context 'when serial > 1' do
          let(:next_payment) { create(:payment, :success_without_lock, order: order) }

          before { payment_success }

          it 'still create new schedule' do
            schedule = next_payment.schedules.where(schedulable_type: :Payment, event: :rent_payout).last
            expect(schedule.schedule_at.to_date).to eq(payment_success.service_start_at.to_date + 38.days)
          end
        end
      end

      context 'with one month rent payout type' do
        let(:order) { create(:order, :with_one_month_rent_payout_type) }

        it 'schedule on the service_start_at + 13 days' do
          schedule = payment_success.schedules.where(schedulable_type: :Payment, event: :rent_payout).order(id: :asc).first
          expect(schedule.schedule_at.to_date).to eq(payment_success.service_start_at.to_date + 13.days)
        end

        context 'when serial > 1' do
          let(:next_payment) { create(:payment, :success_without_lock, order: order) }

          before { payment_success }

          it 'still create new schedule' do
            schedule = next_payment.schedules.where(schedulable_type: :Payment, event: :rent_payout).last
            expect(schedule.schedule_at.to_date).to eq(payment_success.service_start_at.to_date + 43.days)
          end
        end
      end
    end
  end

  describe '#retry!' do
    subject(:payment_retry) { payment.retry! }

    let(:payment) { create(:payment, order: order) }

    it { expect { payment_retry }.to change(payment, :retry_count).to(1) }
  end

  describe '#fail!' do
    subject(:payment_fail) { payment.fail! }

    let(:payment) { create(:payment, :retry, order: order) }

    it { expect { payment_fail }.to change(payment, :failed_at) }
  end

  # TODO: Validate update order and schedule next payment
  describe '#resolve!' do
    subject(:payment_resolve) { payment.resolve! }

    let(:payment) { create(:payment, :fail, order: order) }
    let(:payment_service) { instance_double(Accounting::PaymentService) }

    before do
      allow(Accounting::PaymentService).to receive(:new).and_return(payment_service)
      allow(payment_service).to receive(:start)
    end

    it 'is expected to change #resolved_at' do
      expect { payment_resolve }.to change(payment, :resolved_at)
    end

    describe '#schedule rent payout' do
      it 'schedule rent payout' do
        payment_resolve
        schedule = payment.schedules.where(schedulable_type: :Payment, event: :rent_payout).order(id: :asc).first
        expect(schedule.schedule_at.to_date).to eq(payment.service_start_at.to_date + 8.days)
      end
    end
  end

  describe '#host_rent' do
    let(:payment) { create(:payment, order: order) }

    def calculate_amount(service_period, order)
      duration = (service_period[:end_date].to_date - service_period[:start_date].to_date).to_i + 1
      duration * order.price * (1 - order.service_fee_host_rate)
    end

    context 'with whole month' do
      let(:service_period) { { start_date: payment.service_start_at, end_date: payment.service_end_at } }

      it { expect(payment.host_rent).to eq(calculate_amount(service_period, order)) }
    end

    context 'when long term cancelled' do
      let(:service_period) { { start_date: payment.service_start_at, end_date: order.long_term_cancelled_at } }

      before do
        order.update(long_term_cancelled_at: order.start_at + rand(7..27))
      end

      it { expect(payment.host_rent).to eq(calculate_amount(service_period, order)) }
    end

    context 'when payoff' do
      let(:service_period) { { start_date: order.start_at, end_date: order.end_at } }
      let(:order) { create(:order, :payoff, space: space) }

      it { expect(payment.host_rent).to eq(calculate_amount(service_period, order)) }
    end
  end

  describe 'Refund should follow SND cancellation policy' do
    subject(:payment) { create(:payment, order: order) }

    before { payment }

    it '#refund 100% rent policy' do
      order.update(cancelled_at: order.start_at - rand(16..18))

      # amount = payment.rent #use this line to resolve CONFLICT when #721 merged to develop
      amount = payment.rent + payment.deposit
      expect(payment.refund).to eq(amount)
    end

    it '#refund 50% rent policy' do
      order.update(cancelled_at: order.start_at - rand(8..14))

      # amount = (payment.rent * 0.5) #use this line to resolve CONFLICT when #721 merged to develop
      amount = (payment.rent * 0.5) + payment.deposit
      expect(payment.refund).to eq(amount)
    end

    it '#refund 0% rent policy' do
      order.update(cancelled_at: order.start_at - rand(1..7))

      # amount = Money.new(0) #use this line to resolve CONFLICT when #721 merged to develop
      amount = payment.deposit
      expect(payment.refund).to eq(amount)
    end

    describe '#refund admin full_refund' do
      subject(:payment) { create(:payment, :success, order: order) }

      before { payment }

      it 'full_refund' do
        OrderFullRefundService.new(order).start!

        amount = payment.amount
        expect(order.last_payment.amount).to eq(amount)
      end
    end

    context 'with insurance enable' do
      subject(:payment) { create(:payment, order: order) }

      let(:order) { create(:order, :with_premium) }

      before { payment }

      it '#refund 100% rent policy' do
        order.update(cancelled_at: order.start_at - rand(16..18))

        # amount = payment.rent + payment.premium #use this line to resolve CONFLICT when #721 merged to develop
        amount = payment.rent + payment.deposit + payment.premium
        expect(payment.refund).to eq(amount)
      end

      it '#refund 50% rent policy' do
        order.update(cancelled_at: order.start_at - rand(8..14))

        # amount = (payment.rent * 0.5) + payment.premium #use this line to resolve CONFLICT when #721 merged to develop
        amount = (payment.rent * 0.5) + payment.deposit + payment.premium
        expect(payment.refund).to eq(amount)
      end

      it '#refund 0% rent policy' do
        order.update(cancelled_at: order.start_at - rand(1..7))

        # amount = payment.premium #use this line to resolve CONFLICT when #721 merged to develop
        amount = payment.deposit + payment.premium
        expect(payment.refund).to eq(amount)
      end

      describe '#refund admin full_refund' do
        subject(:payment) { create(:payment, :success, order: order) }

        let(:order) { create(:order, :with_premium) }

        it 'full_refund' do
          OrderFullRefundService.new(order).start!

          amount = payment.amount
          expect(order.last_payment.amount).to eq(amount)
        end
      end
    end
  end

  describe '#remain_rent_payout?' do
    subject(:payment) { create(:payment, order: order) }

    context 'with one month rent payout type' do
      let(:order) { create(:order, :with_one_month_rent_payout_type) }

      it { expect(payment.remain_rent_payout?).to be true }
    end

    context 'with ten days rent payout type' do
      let(:order) { create(:order, :with_ten_days_rent_payout_type) }

      def create_payout
        create(:payout, :rent_payout_cycle, payment: payment)
      end

      context 'when payouts not exist' do
        it { expect(payment.remain_rent_payout?).to be true }
      end

      context 'when first payout exist' do
        before { create_payout }

        it { expect(payment.remain_rent_payout?).to be true }
      end

      context 'when second payout exist' do
        before { 2.times { create_payout } }

        it { expect(payment.remain_rent_payout?).to be true }
      end

      context 'when payout has all payoff' do
        before { 3.times { create_payout } }

        it { expect(payment.remain_rent_payout?).to be false }
      end

      context 'when long_term_cancelled_at setup, and payment has all payoff' do
        subject(:payment) { create(:payment, order: order, service_end_at: order.long_term_cancelled_at) }

        before do
          order.update(long_term_cancelled_at: order.start_at + rand(7..27))
          create(:payout, payment: payment, end_at: payment.service_end_at)
        end

        it { expect(payment.remain_rent_payout?).to be false }
      end

      context 'when long_term_cancelled_at setup, and need to refund and payment has all payoff' do
        subject(:payment) { create(:payment, order: order, service_end_at: order.long_term_cancelled_at) }

        before do
          order.update(long_term_cancelled_at: order.start_at + rand(7..27))
          create(:payout, payment: payment, end_at: order.long_term_cancelled_at)
        end

        it { expect(payment.remain_rent_payout?).to be false }
      end
    end
  end

  describe '#last_rent_payout_end_at' do
    subject(:payment) { create(:payment, order: order) }

    context 'with ten days rent payout type' do
      let(:order) { create(:order, :with_ten_days_rent_payout_type) }

      def create_payout
        create(:payout, :rent_payout_cycle, payment: payment)
      end

      context 'when payouts not exist' do
        it { expect(payment.last_rent_payout_end_at.to_date).to eq(payment.service_start_at.to_date - 1.day) }
      end

      context 'when first payout exist' do
        before { create_payout }

        it { expect(payment.last_rent_payout_end_at.to_date).to eq(payment.service_start_at.to_date + 9.days) }
      end

      context 'when second payout exist' do
        before { 2.times { create_payout } }

        it { expect(payment.last_rent_payout_end_at.to_date).to eq(payment.service_start_at.to_date + 19.days) }
      end
    end

    context 'with one month rent payout type' do
      let(:order) { create(:order, :with_one_month_rent_payout_type) }

      it { expect(payment.last_rent_payout_end_at.to_date).to eq(payment.service_start_at.to_date - 1.day) }
    end
  end

  describe '#payout_rent' do
    subject(:payment) { create(:payment, order: order) }

    context 'with ten days rent payout type' do
      let(:order) { create(:order, :with_ten_days_rent_payout_type) }

      def create_payout
        create(:payout, :rent_payout_cycle, payment: payment)
      end

      context 'when remaining payout days < 10' do
        it 'return remaining days host rent' do
          days_remain = rand(1..9)
          expect_amount = order.price * (1 - order.service_fee_host_rate) * days_remain
          payment.update(service_end_at: payment.service_start_at + (days_remain - 1).days)

          expect(payment.payout_rent).to eq(expect_amount)
        end
      end

      context 'when remainning payout days >= 10 day in this payment' do
        it 'return 1/3 host rent (10 days) of full month payment' do
          expect_amount = payment.rent * (1 - order.service_fee_host_rate) / 3

          expect(payment.payout_rent).to eq(expect_amount)
        end
      end

      context 'when host rent is all payoff in this payment' do
        before { 3.times { create_payout } }

        it { expect(payment.payout_rent).to eq(Money.new(0, 'SGD')) }
      end
    end
  end

  describe '#payout_host_service_fee' do
    subject(:payment) { create(:payment, order: order) }

    context 'with ten days rent payout type' do
      let(:order) { create(:order, :with_ten_days_rent_payout_type) }

      def create_payout
        create(:payout, :rent_payout_cycle, payment: payment)
      end

      context 'when remaining payout days < 10' do
        it 'return remaining days host rent service fee' do
          days_remain = rand(3..9)
          expect_amount = order.price * order.service_fee_host_rate * days_remain
          payment.update(service_end_at: payment.service_start_at + (days_remain - 1).days)

          expect(payment.payout_host_service_fee).to eq(expect_amount)
        end
      end

      context 'when remainning payout days >= 10 day in this payment' do
        it 'return 1/3 host rent service fee (10 days) of full month payment' do
          expect_amount = payment.rent * order.service_fee_host_rate / 3

          expect(payment.payout_host_service_fee).to eq(expect_amount)
        end
      end

      context 'when host rent is all payoff in this payment' do
        before { 3.times { create_payout } }

        it { expect(payment.payout_host_service_fee).to eq(Money.new(0, 'SGD')) }
      end
    end

    context 'with one month rent payout type' do
      let(:order) { create(:order, :with_one_month_rent_payout_type) }

      it { expect(payment.payout_host_service_fee).to eq(payment.rent * order.service_fee_host_rate) }

      context 'when payment service days not enough one month' do
        it 'return remaining days host rent service fee' do
          days_remain = rand(3..9)
          expect_amount = order.price * order.service_fee_host_rate * days_remain
          payment.update(service_end_at: payment.service_start_at + (days_remain - 1).days)

          expect(payment.payout_host_service_fee).to eq(expect_amount)
        end
      end
    end
  end

  describe '#payout_start_at' do
    subject(:payment) { create(:payment, order: order) }

    context 'with ten days rent payout type' do
      let(:order) { create(:order, :with_ten_days_rent_payout_type) }

      def create_payout
        create(:payout, :rent_payout_cycle, payment: payment)
      end

      context 'when payouts not exist' do
        it { expect(payment.payout_start_at.to_date).to eq(payment.service_start_at.to_date) }
      end

      context 'when first payout exist' do
        before { create_payout }

        it { expect(payment.payout_start_at.to_date).to eq(payment.service_start_at.to_date + 10.days) }
      end

      context 'when second payout exist' do
        before { 2.times { create_payout } }

        it { expect(payment.payout_start_at.to_date).to eq(payment.service_start_at.to_date + 20.days) }
      end
    end

    context 'with one month rent payout type' do
      let(:order) { create(:order, :with_one_month_rent_payout_type) }

      it { expect(payment.payout_start_at.to_date).to eq(payment.service_start_at.to_date) }
    end
  end

  describe '#payout_end_at' do
    subject(:payment) { create(:payment, order: order) }

    context 'with ten days rent payout type' do
      let(:order) { create(:order, :with_ten_days_rent_payout_type) }

      def create_payout
        create(:payout, :rent_payout_cycle, payment: payment)
      end

      context 'when payouts not exist' do
        it { expect(payment.payout_end_at.to_date).to eq(payment.service_start_at.to_date + 9.days) }
      end

      context 'when first payout exist' do
        before { create_payout }

        it { expect(payment.payout_end_at.to_date).to eq(payment.service_start_at.to_date + 19.days) }
      end

      context 'when second payout exist' do
        before { 2.times { create_payout } }

        it { expect(payment.payout_end_at.to_date).to eq(payment.service_start_at.to_date + 29.days) }
      end

      context 'when long term cancelled and long_term_cancelled_at - last_rent_payout_end_at < 10' do
        before { create_payout }

        it 'expect return long_term_cancelled_end date' do
          duration = rand(2..9)
          order.update(long_term_cancelled_at: payment.last_rent_payout_end_at.to_date + duration.days)

          expect(payment.payout_end_at.to_date).to eq(order.long_term_cancelled_at.to_date)
        end
      end
    end

    context 'with one month rent payout type' do
      let(:order) { create(:order, :with_one_month_rent_payout_type) }

      it { expect(payment.payout_end_at.to_date).to eq(payment.service_end_at.to_date) }

      context 'when long term cancelled and long_term_cancelled_at - last_rent_payout_end_at < 30' do
        it 'expect return long_term_cancelled_end date' do
          duration = rand(2..29)
          order.update(long_term_cancelled_at: payment.last_rent_payout_end_at.to_date + duration.days)

          expect(payment.payout_end_at.to_date).to eq(order.long_term_cancelled_at.to_date)
        end
      end
    end
  end

  describe '#present_available_end_date' do
    subject(:payment) { create(:payment, order: order) }

    context 'with ten days rent payout type' do
      let(:order) { create(:order, :with_ten_days_rent_payout_type) }

      it { expect(payment.present_available_end_date.to_date).to eq(payment.service_end_at.to_date) }

      context 'when order is payoff' do
        let(:order) { create(:order, :payoff, :with_ten_days_rent_payout_type) }

        it { expect(payment.present_available_end_date.to_date).to eq(order.end_at.to_date) }
      end

      context 'when order is long term and setup long_term_cancelled_at before payment' do
        before do
          order.update(long_term: true, long_term_cancelled_at: order.start_at + rand(7..27))
          payment.update(service_end_at: order.long_term_cancelled_at)
          puts "order #{order.start_at} - #{order.end_at} /// #{order.long_term_cancelled_at}"
          puts "payment #{payment.service_start_at} - #{payment.service_end_at}"
        end

        it { expect(payment.present_available_end_date).to eq(order.long_term_cancelled_at.to_date) }
        it { expect(payment.present_available_end_date).to eq(payment.service_end_at.to_date) }
      end

      context 'when order is long term and setup long_term_cancelled_at date at payment service period' do
        before do
          payment
          order.update(long_term: true, long_term_cancelled_at: order.start_at + rand(7..27))
        end

        it { expect(payment.present_available_end_date).to eq(order.long_term_cancelled_at.to_date) }
        it { expect(payment.present_available_end_date).not_to eq(payment.service_end_at.to_date) }
      end
    end

    context 'with one month rent payout type' do
      let(:order) { create(:order, :with_one_month_rent_payout_type) }

      it { expect(payment.present_available_end_date.to_date).to eq(payment.service_end_at.to_date) }

      context 'when order is payoff' do
        let(:order) { create(:order, :payoff, :with_one_month_rent_payout_type) }

        it { expect(payment.present_available_end_date.to_date).to eq(order.end_at.to_date) }
      end

      context 'when order is long term and setup long_term_cancelled_at before payment' do
        before do
          order.update(long_term: true, long_term_cancelled_at: order.start_at + rand(7..27))
          payment.update(service_end_at: order.long_term_cancelled_at)
        end

        it { expect(payment.present_available_end_date).to eq(order.long_term_cancelled_at.to_date) }
        it { expect(payment.present_available_end_date).to eq(payment.service_end_at.to_date) }
      end

      context 'when order is long term and setup long_term_cancelled_at date at payment service period' do
        before do
          payment
          order.update(long_term: true, long_term_cancelled_at: order.start_at + rand(7..27))
        end

        it { expect(payment.present_available_end_date).to eq(order.long_term_cancelled_at.to_date) }
        it { expect(payment.present_available_end_date).not_to eq(payment.service_end_at.to_date) }
      end
    end
  end

  describe '#days_rented' do
    subject(:payment) { create(:payment, order: order) }

    it 'return full period of payments' do
      duration = (payment.service_end_at.to_date - payment.service_start_at.to_date).to_i + 1
      expect(payment.days_rented).to eq(duration)
    end

    context 'when long term cancelled' do
      before do
        payment
        order.update(long_term_cancelled_at: order.start_at + rand(7..27))
      end

      it 'return days between the service start date and long term cancelled date' do
        duration = (order.long_term_cancelled_at.to_date - payment.service_start_at.to_date).to_i + 1
        expect(payment.days_rented).to eq(duration)
      end
    end

    context 'when payoff' do
      subject(:payment) { create(:payment, order: order) }

      let(:order) { create(:order, :payoff, space: space) }

      it { expect(payment.days_rented).to eq(order.days) }
    end
  end

  describe '#refund_due?' do
    subject(:payment) { create(:payment, order: order) }

    it { expect(payment).not_to be_refund_due }

    context 'with refund' do
      before do
        payment
        order.update(long_term_cancelled_at: order.start_at + rand(7..27))
      end

      it { expect(payment.refund_due?).to be true }
    end
  end
end
