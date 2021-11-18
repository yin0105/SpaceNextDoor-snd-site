# frozen_string_literal: true

module Orders
  class PaymentsController < ApplicationController
    include PaymentErrorHandler

    skip_authorization_check only: [:well_done]

    rescue_from VerifyPaymentService::OrderStatusError do |e|
      redirect_to order_path(@order), flash: { error: e.message }
    end

    def create
      load_order
      authorize! :read, @order

      if unpayable?
        redirect_to order_path(@order), flash: { error: I18n.t('snd.errors.already_schedule_payment') }
      else
        service.start!
        redirect_to well_done_order_payments_path(@order)
      end
    end

    def well_done; end

    private

    def service
      return ResumePaymentService.new(@order) if incomplete_payment?

      CreatePaymentService.new(@order)
    end

    def incomplete_payment?
      @order.payments.failed.last.present?
    end

    def load_order
      @order ||= order_scope.find(params[:order_id])
    end

    def order_scope
      current_guest.orders
    end

    def unpayable?
      @order.active? && @order.payments.failed.empty?
    end
  end
end
