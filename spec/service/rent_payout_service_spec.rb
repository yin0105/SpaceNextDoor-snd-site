# frozen_string_literal: true

require 'rails_helper'

describe 'RentPayoutServiceSpec' do
  before(:all) { @space = create(:space, :activated, :two_years) }

  describe 'create payouts' do
    subject { RentPayoutService.new(@order.last_payment).start! }

    before { @order = create(:order, :with_payments, space: @space) }

    it 'increase 1 payouts' do
      expect { subject }.to change { @order.payouts.count }.by(1)
    end

    it '10 service days duration' do
      subject
      duration = (@order.last_payment.last_rent_payout.end_at.to_date - @order.last_payment.last_rent_payout.start_at.to_date).to_i + 1
      expect(duration).to eq(10)
    end

    it 'start at the payment service_start_at date' do
      subject
      expect(@order.last_payment.last_rent_payout.start_at.to_date).to eq(@order.last_payment.service_start_at.to_date)
    end

    it 'contain 1/3 payment host rent ' do
      subject
      period_host_rent = @order.last_payment.rent * (1 - @order.service_fee_host_rate) / 3
      expect(@order.last_payment.last_rent_payout.amount).to eq(period_host_rent)
    end

    context 'when this is the last payout of the payment' do
      it 'end at date is payment service end date' do
        create(:payout, payment: @order.last_payment, start_at: @order.start_at, end_at: @order.last_payment.service_end_at - 10.days)
        subject
        expect(@order.last_payment.last_rent_payout.end_at.to_date).to eq(@order.last_payment.service_end_at.to_date)
      end

      context 'while long term cancelled with refund' do
        before do
          @duration = rand(10..19)
          @order.update(long_term_cancelled_at: @order.last_payment.service_end_at - @duration.days)
          create(:payout, :rent_payout_cycle, payment: @order.last_payment)
        end

        it 'end date is long_term_cancelled_at date' do
          subject
          expect(@order.last_payment.last_rent_payout.end_at.to_date).to eq(@order.long_term_cancelled_at)
        end
      end

      context 'while payoff' do
        before do
          @payoff_order = create(:order, :payoff_11_20_days, :with_payments, space: @space)
          create(:payout, :rent_payout_cycle, payment: @payoff_order.last_payment)
        end

        it 'end date is order end_at date' do
          RentPayoutService.new(@payoff_order.last_payment).start!
          expect(@payoff_order.last_payment.last_rent_payout.end_at.to_date).to eq(@payoff_order.end_at)
        end
      end
    end
  end

  describe 'schedule next rent payout' do
    subject { RentPayoutService.new(@order.last_payment).start! }

    before { @order = create(:order, :with_payments, space: @space) }

    it 'schedule number increase 1' do
      expect { subject }.to change { @order.last_payment.schedules.where(event: :rent_payout).count }.by(1)
    end

    it 'at 9 days after payout end_at' do
      subject
      @order.reload
      schedule_date = @order.last_payment.last_rent_payout.end_at.to_date + 9.days
      last_schedule = @order.last_payment.schedules.where(event: :rent_payout).order(id: :asc).last
      expect(last_schedule.schedule_at.to_date).to eq(schedule_date)
    end

    it 'at payments service_end_at - 1 day when 2nd payout generate' do
      2.times { RentPayoutService.new(@order.last_payment).start! }
      @order.reload
      schedule_date = @order.last_payment.service_end_at.to_date - 1.day
      last_schedule = @order.last_payment.schedules.where(event: :rent_payout).order(id: :asc).last
      expect(last_schedule.schedule_at.to_date).to eq(schedule_date)
    end

    it 'wont schedule when last payout of payment' do
      2.times { subject }
      @order.reload
      expect { subject }.to change { @order.last_payment.schedules.where(event: :rent_payout).count }.by(0)
    end

    context 'when payoff order' do
      before do
        @payoff_order = create(:order, :payoff_21_29_days, :with_payments, space: @space)
        create(:payout, :rent_payout_cycle, payment: @payoff_order.last_payment)
      end

      it 'schedule at order end_at - 1 date' do
        RentPayoutService.new(@payoff_order.last_payment).start!
        last_schedule = @payoff_order.last_payment.schedules.where(event: :rent_payout).order(id: :asc).last
        expect(last_schedule.schedule_at.to_date).to eq(@payoff_order.end_at.to_date - 1.day)
      end
    end

    context 'when long term cancelled with refund' do
      before do
        @duration = rand(10..19)
        @order.update(long_term_cancelled_at: @order.last_payment.service_end_at - @duration.days)
      end

      it 'schedule at long term cancelled at before last payout' do
        subject
        last_schedule = @order.last_payment.schedules.where(event: :rent_payout).order(id: :asc).last
        expect(last_schedule.schedule_at.to_date).to eq(@order.long_term_cancelled_at.to_date - 1.day)
      end

      it 'wont schedule when last payout of payment' do
        subject
        expect { subject }.to change { @order.payouts.count }.by(0)
      end
    end
  end

  describe 'discount order' do
    subject { order.payouts.last.amount }

    context 'one month discount' do
      before { RentPayoutService.new(order.reload.last_payment).start! }

      let(:order) { create(:order, :with_payments, :with_valid_one_month_discount) }

      context '1st payout amount should be zero' do
        before { order.reload }

        it { is_expected.to eq(0.to_money) }
      end

      context '2nd payout amount should be zero' do
        before { RentPayoutService.new(order.reload.last_payment).start! }

        it { is_expected.to eq(0.to_money) }
      end

      context '3rd payout amount should be zero' do
        before { 2.times { RentPayoutService.new(order.reload.last_payment).start! } }

        it { is_expected.to eq(0.to_money) }
      end

      context 'start from 4rd payout amount should not be zero' do
        before do
          2.times { RentPayoutService.new(order.reload.payments.last).start! }
          create(:payment, :success, order: order)
          3.times { RentPayoutService.new(order.reload.payments.last).start! }
        end

        it { is_expected.not_to eq(0.to_money) }
      end
    end

    context 'two months discount' do
      let(:order) { create(:order, :with_payments, :with_valid_two_months_discount) }

      context '1st payout amount should be zero' do
        before { RentPayoutService.new(order.last_payment).start! }

        before { order.reload }

        it { is_expected.to eq(0.to_money) }
      end

      context '2nd payout amount should be zero' do
        before { 2.times { RentPayoutService.new(order.reload.last_payment).start! } }

        it { is_expected.to eq(0.to_money) }
      end

      context '3rd payout amount should be zero' do
        before { 3.times { RentPayoutService.new(order.reload.last_payment).start! } }

        it { is_expected.to eq(0.to_money) }
      end

      context '16th payout amount should be zero' do
        before do
          3.times { RentPayoutService.new(order.reload.last_payment).start! }
          4.times do
            create(:payment, :success, order: order)
            3.times { RentPayoutService.new(order.reload.payments.last).start! }
          end
          create(:payment, :success, order: order)
          RentPayoutService.new(order.reload.payments.last).start!
        end

        it { is_expected.to eq(0.to_money) }
      end

      context '17th payout amount should be zero' do
        before do
          3.times { RentPayoutService.new(order.reload.last_payment).start! }
          4.times do
            create(:payment, :success, order: order)
            3.times { RentPayoutService.new(order.reload.payments.last).start! }
          end
          create(:payment, :success, order: order)
          2.times { RentPayoutService.new(order.reload.payments.last).start! }
        end

        it { is_expected.to eq(0.to_money) }
      end

      context '18th payout amount should be zero' do
        before do
          3.times { RentPayoutService.new(order.reload.last_payment).start! }
          4.times do
            create(:payment, :success, order: order)
            3.times { RentPayoutService.new(order.reload.payments.last).start! }
          end
          create(:payment, :success, order: order)
          3.times { RentPayoutService.new(order.reload.payments.last).start! }
        end

        it { is_expected.to eq(0.to_money) }
      end

      context '19th payout amount should not be zero' do
        before do
          3.times { RentPayoutService.new(order.reload.last_payment).start! }
          5.times do
            create(:payment, :success, order: order)
            3.times { RentPayoutService.new(order.reload.payments.last).start! }
          end
          create(:payment, :success, order: order)
          1.times { RentPayoutService.new(order.reload.payments.last).start! }
        end

        it { is_expected.not_to eq(0.to_money) }
      end
    end

    context '6 months discount with 50%' do
      let(:order) { create(:order, :with_valid_six_months_discount) }

      # rubocop:disable RSpec/ExampleLength
      it '1st to 18th payout should be 50%' do
        6.times do
          create(:payment, :success, order: order)
          3.times do
            next_payout_rent = order.reload.last_payment.payout_rent
            RentPayoutService.new(order.reload.payments.last).start!
            expect(order.reload.payouts.last.amount).to eq(next_payout_rent / 2)
          end
        end
      end

      it '19th payout should be 100%' do
        6.times do
          create(:payment, :success, order: order)
          3.times { RentPayoutService.new(order.reload.payments.last).start! }
        end

        create(:payment, :success, order: order)
        next_payout_rent = order.reload.last_payment.payout_rent
        RentPayoutService.new(order.reload.payments.last).start!
        expect(order.reload.payouts.last.amount).to eq(next_payout_rent)
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
