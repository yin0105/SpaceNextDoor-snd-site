# frozen_string_literal: true

require 'rails_helper'

describe 'ToggleSpaceInsuranceService' do
  describe 'space insurance enable turn to disable' do
    subject { ToggleSpaceInsuranceService.new(@space).start! }

    before { @space = create(:space, :default_insurance_enable_property, :activated) }

    it 'space insurance enable changed' do
      subject
      expect(@space.insurance_enable).to eq(false)
    end

    context 'orders that belongs to the space' do
      it 'default attributes after change' do
        order = create(:order, space: @space)

        subject

        expect(@space.orders.first.insurance_enable).to eq(false)
        expect(@space.orders.first.insurance_type).to eq('coverage_null')
        expect(@space.orders.first.premium_cents).to eq(0)
      end

      context 'orders that can changed' do
        it 'pending order' do
          order = create(:order, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(false)
        end

        it 'order that active and has next payment schedule' do
          order = create(:order, :with_payments, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(false)
        end

        it 'order with payment failed' do
          order = create(:order, :with_failed_payments, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(false)
        end

        it 'order with payment retry' do
          order = create(:order, :with_retry_payments, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(false)
        end
      end

      context 'active order without next payment schedule can not changed' do
        it 'short term with payment success' do
          order = create(:order, :with_payments, :payoff, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(true)
        end

        it 'long term order that active but without next payment schedule' do
          order = create(:order, :with_payments, :long_term, space: @space)

          order.schedules.scheduled.where(event: :payment).first.cancel!

          subject

          expect(@space.orders.first.insurance_enable).to eq(true)
        end
      end
    end
  end

  describe 'space insurance disable turn to enable' do
    subject { ToggleSpaceInsuranceService.new(@space).start! }

    before do
      @space = create(:space, :default_insurance_disable_property, :activated)
    end

    it 'space insurance enable changed' do
      subject
      expect(@space.insurance_enable).to eq(true)
    end

    context 'orders that belongs to the space' do
      it 'default attributes after change' do
        order = create(:order, space: @space)

        subject

        expect(@space.orders.first.insurance_enable).to eq(true)
        expect(@space.orders.first.insurance_type).to eq('coverage_1000')
        expect(@space.orders.first.premium_cents).to eq(300)
      end

      context 'orders that can changed' do
        it 'pending order' do
          order = create(:order, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(true)
        end

        it 'order that active and has next payment schedule' do
          order = create(:order, :with_payments, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(true)
        end

        it 'order with payment failed' do
          order = create(:order, :with_failed_payments, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(true)
        end

        it 'order with payment retry' do
          order = create(:order, :with_retry_payments, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(true)
        end
      end

      context 'active order without next payment schedule can not changed' do
        it 'short term payment success' do
          order = create(:order, :with_payments, :payoff, space: @space)

          subject

          expect(@space.orders.first.insurance_enable).to eq(false)
        end

        it 'long term order that active but without next payment schedule' do
          order = create(:order, :with_payments, :long_term, space: @space)

          order.schedules.scheduled.where(event: :payment).first.cancel!

          subject

          expect(@space.orders.first.insurance_enable).to eq(false)
        end
      end
    end
  end
end
