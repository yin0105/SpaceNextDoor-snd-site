# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LateFeePayment, type: :model do
  subject { create(:late_fee_payment) }

  before do
    described_class.aasm.state_machine.config.no_direct_assignment = false
    Order.aasm.state_machine.config.no_direct_assignment = false
  end

  before(:all) do
    @space = create(:space, :activated, :two_years)
  end

  let(:payment) { create(:late_fee_payment) }

  it { is_expected.to belong_to(:order) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:payment_type) }
  it { is_expected.to validate_presence_of(:identifier) }
  it { is_expected.to validate_presence_of(:service_start_at) }
  it { is_expected.to validate_presence_of(:service_end_at) }
  it { is_expected.to monetize(:rent) }
  it { is_expected.to monetize(:deposit) }
  it { is_expected.to monetize(:guest_service_fee) }

  describe 'lifecycles' do
    describe 'after create' do
      it "service_start_at shouldn't be ealier than order last payment end_at" do
        subject.service_start_at = subject.order.last_payment.service_end_at - 1.day
        expect(subject).not_to be_valid
      end
    end

    subject { create(:late_fee_payment, :success_without_lock) }

    describe 'schedule rent payout' do
      it 'shedule on the service_start_at' do
        schedule = subject.schedules.where(schedulable_type: :Payment, event: :rent_payout).order(id: :asc).first
        expect(schedule.schedule_at.to_date).to eq(subject.service_start_at.to_date + 8.days)
      end
    end
  end

  describe 'after retry' do
    subject { create(:late_fee_payment) }

    it 'retry_count increment by 1' do
      expect { subject.retry! }.to change(subject, :retry_count).by(1)
    end
  end

  describe 'after fail' do
    subject { create(:late_fee_payment) }

    it 'retry_count increment by 1' do
      subject.status = :retry
      subject.fail!
      expect(subject.failed_at).not_to eq(nil)
    end
  end

  describe 'after resolve' do
    before do
      subject.status = :failed
      subject.resolve!
    end

    it 'retry_count increment by 1' do
      expect(subject.resolved_at).not_to eq(nil)
    end

    it 'schedule rent payout on service start date + 8' do
      schedule = subject.schedules.where(schedulable_type: :Payment, event: :rent_payout).order(id: :desc).first
      expect(schedule.schedule_at.to_date).to eq(subject.service_start_at.to_date + 8)
    end
  end
end

describe 'multiple payments' do
  describe 'deposit column' do
    context 'the first payment for the order' do
      subject { create(:late_fee_payment) }

      it 'deposit should equal to zero' do
        expect(subject.deposit).to eq(Money.new(0, 'SGD'))
      end
    end
  end

  describe 'guest_service_fee column' do
    subject { create(:late_fee_payment) }

    it 'equals default rate * rent' do
      expect(subject.guest_service_fee).to eq(subject.rent * Settings.service_fee.guest_rate)
    end
  end

  describe 'host_service_fee column' do
    subject { create(:late_fee_payment) }

    it 'equals default rate * rent' do
      expect(subject.host_service_fee).to eq(subject.rent * Settings.service_fee.host_rate)
    end

    it '#amount' do
      amount = subject.rent + subject.guest_service_fee
      expect(subject.amount).to eq(amount)
    end
  end
end

describe '#host_rent' do
  subject { create(:late_fee_payment) }

  it 'return host rent' do
    duration = (subject.service_end_at.to_date - subject.service_start_at.to_date).to_i + 1
    amount = duration * subject.order.price * (1 - subject.order.service_fee_host_rate)
    expect(subject.host_rent).to eq(amount)
  end
end
