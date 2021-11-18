# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orders::PaymentsController, type: :controller do
  subject { create(:order, guest: user.as_guest, space: @space) }

  before(:all) { @space = create(:space, :two_years, :activated) }

  let(:user) { create(:user, :with_payment_method) }

  before do
    Order.aasm.state_machine.config.no_direct_assignment = false
    Payment.aasm.state_machine.config.no_direct_assignment = false
    login(user)
  end

  def create_payment_from(order)
    post :create, params: { order_id: order.id }
  end

  describe 'POST #create' do
    context 'success' do
      before { allow(Stripe::Charge).to receive(:create).and_return('id' => '123456789') }

      context 'the status of the order of payment is pending' do
        it 'returns http success' do
          expect { create_payment_from(subject) }.not_to raise_error
          expect(response).to redirect_to(well_done_order_payments_path(assigns(:order)))
          expect(subject.payments.last).to be_success
        end
      end

      context 'order has been failed payment' do
        let!(:payment) { create(:payment, user: subject.guest.as_user, order: subject) }

        before { payment.update(status: :failed) }

        it 'raise OrderStatusError' do
          create_payment_from(subject)
          expect(response).to redirect_to(well_done_order_payments_path(assigns(:order)))
          expect(payment.reload).to be_resolved
        end
      end
    end

    context 'failure' do
      context "user din't setup payment method" do
        let(:user) { create(:user) }

        it 'raise InvalidPaymentMethodError' do
          bypass_rescue
          expect { create_payment_from(subject) }.to raise_error InitializePaymentService::InvalidPaymentMethodError
        end
      end

      context "payment's order has been cancelled" do
        it 'raise OrderStatusError' do
          subject.update(status: :cancelled)

          bypass_rescue
          expect { create_payment_from(subject) }.to raise_error VerifyPaymentService::OrderStatusError
        end
      end

      context "payment's order has been activated" do
        it 'raise OrderStatusError' do
          subject.update(status: :active)
          create_payment_from(subject)
          expect(response).to redirect_to(order_path(subject))
          expect(flash[:error]).not_to be_nil
        end
      end

      context "payment's order has been completed" do
        it 'raise OrderStatusError' do
          subject.update(status: :completed)

          bypass_rescue
          expect { create_payment_from(subject) }.to raise_error VerifyPaymentService::OrderStatusError
        end
      end
    end
  end
end
