# frozen_string_literal: true

require 'rails_helper'

describe 'OrderResheduleServiceSpec' do
  subject { OrderRescheduleService.new(@order).start! }

  before(:all) { @space = create(:space, :activated, :two_years) }

  before { @order = create(:order, :with_payments, space: @space) }

  describe 'reschedule jobs' do
    context 'when long term cancelled order with refund' do
      before do
        @order.update(long_term_cancelled_at: @order.last_payment.service_start_at + rand(1..8).day)
      end

      it 'cancel next payment schedule' do
        expect { subject }.to change { @order.schedules.where(event: :payment).scheduled.count }.from(1).to(0)
      end

      it 'cancel exceed date rent payout schedule' do
        expect { subject }.to change { @order.last_payment.as_payment.schedules.where(event: :rent_payout).cancelled.count }.from(0).to(1)
      end

      it 'reschedule exceed date rent payout schedule at long term cancelled date - 1 day' do
        subject
        payout_schedule = @order.last_payment.as_payment.schedules.where(event: :rent_payout).scheduled.last
        expect(payout_schedule.schedule_at.to_date).to eq(@order.long_term_cancelled_at.to_date - 1.day)
      end

      it 'no schedules later then lease end date' do
        subject
        schedules = Schedule.scheduled.where('schedule_at > ?', @order.long_term_cancelled_at.to_date)
        expect(schedules).to be_empty
      end

      context 'while lease end job was scheduled' do
        before { @order.last_payment.as_payment.schedule(:service_end, at: @order.last_payment.service_end_at) }

        it 'cancel lease end job' do
          expect { subject }.to change { @order.last_payment.schedules.cancelled.where(event: :service_end).count }.from(0).to(1)
        end

        it 'reschedule lease end job' do
          subject
          lease_end_schedule = @order.last_payment.schedules.scheduled.where(event: :service_end).last
          expect(lease_end_schedule.schedule_at.to_date).to eq(@order.long_term_cancelled_at.to_date - 1.day)
        end
      end
    end

    context 'when long term cancelled order with no refund' do
      context "while long term cancelled date isn't payment service end date" do
        before { @order.update(long_term_cancelled_at: @order.last_payment.service_end_at + rand(1..29).days) }

        it "won't cancelled any schedule" do
          expect { subject }.to change { Schedule.cancelled.count }.by(0)
        end
      end

      context 'while long term cancelled date is payment service end date' do
        before { @order.update(long_term_cancelled_at: @order.last_payment.service_end_at) }

        it 'next payment schedule' do
          expect { subject }.to change { @order.schedules.where(event: :payment).scheduled.count }.from(1).to(0)
        end
      end
    end
  end
end
