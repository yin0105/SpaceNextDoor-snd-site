# frozen_string_literal: true

require 'rails_helper'

describe 'ChangeOrderInsuranceService' do
  describe 'orders insurance attributes can be changed' do
    subject do
      @space.update(insurance_enable: false)

      ChangeOrderInsuranceService.new(@order, nil).start!
    end

    before { @space = create(:space, :activated, :insurance_enable) }

    it 'pending order' do
      @order = create(:order, :insurance_enable, space: @space)

      subject

      expect(@order.insurance_enable).to eq(false)
    end

    it 'long term order that active and has next payment schedule' do
      @order = create(:order, :with_payments, :insurance_enable, space: @space)

      subject

      expect(@order.insurance_enable).to eq(false)
    end
  end

  describe 'orders insurance attributes can not be changed' do
    subject do
      @space.update(insurance_enable: false)

      ChangeOrderInsuranceService.new(@order, nil).start!
    end

    before { @space = create(:space, :activated, :default_insurance_enable_property) }

    it 'long term order that active but without next payment schedule' do
      @order = create(:order, :with_payments, :long_term, :insurance_enable, space: @space)
      @order.schedules.scheduled.where(event: :payment).first.cancel!

      subject

      expect(@order.insurance_enable).to eq(true)
    end

    it 'short term with success payment' do
      @order = create(:order, :with_payments, :payoff, :insurance_enable, space: @space)

      subject

      expect(@order.insurance_enable).to eq(true)
    end
  end

  describe 'change orders' do
    before do
      @space = create(:space, :activated, :default_insurance_enable_property)
      @order = create(:order, space: @space)
    end

    context 'change by admin' do
      it 'space insurance turn to enable' do
        @space.update(insurance_enable: true)

        ChangeOrderInsuranceService.new(@order, nil).start!
        expect(@order.insurance_enable).to eq(true)
        expect(@order.insurance_type).to eq('coverage_1000')
        expect(@order.premium_cents).to eq(300)
      end

      it 'space insurance turn to disable' do
        @space.update(insurance_enable: false)

        ChangeOrderInsuranceService.new(@order, nil).start!
        expect(@order.insurance_enable).to eq(false)
        expect(@order.insurance_type).to eq('coverage_null')
        expect(@order.premium_cents).to eq(0)
      end
    end

    context 'change by user' do
      before { ChangeOrderInsuranceService.new(@order, nil).start! }

      it 'change valid' do
        insurance_type = 'coverage_50000'

        ChangeOrderInsuranceService.new(@order, insurance_type).start!

        expect(@order.insurance_enable).to eq(true)
        expect(@order.insurance_type).to eq(insurance_type)
        expect(@order.premium_cents).to eq(5000)
      end

      context 'setting default attribute when change invalid' do
        it 'insurance type without valid value' do
          insurance_type = 'abc'

          ChangeOrderInsuranceService.new(@order, insurance_type).start!

          expect(@order.insurance_enable).to eq(true)
          expect(@order.insurance_type).not_to eq(insurance_type)
          expect(@order.insurance_type).to eq('coverage_1000')
          expect(@order.premium_cents).to eq(300)
        end

        it 'insurance type null' do
          insurance_type = 'coverabe_null'

          ChangeOrderInsuranceService.new(@order, insurance_type).start!

          expect(@order.insurance_enable).to eq(true)
          expect(@order.insurance_type).not_to eq(insurance_type)
          expect(@order.insurance_type).to eq('coverage_1000')
          expect(@order.premium_cents).to eq(300)
        end

        it 'space insurance disable' do
          @space.update(insurance_enable: false)
          insurance_type = 'coverage_50000'

          ChangeOrderInsuranceService.new(@order, insurance_type).start!

          expect(@order.insurance_enable).to eq(false)
          expect(@order.insurance_type).not_to eq(insurance_type)
          expect(@order.insurance_type).to eq('coverage_null')
          expect(@order.premium_cents).to eq(0)
        end
      end
    end
  end
end
