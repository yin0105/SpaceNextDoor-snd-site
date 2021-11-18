# frozen_string_literal: true

module PaymentErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from InitializePaymentService::InvalidPaymentMethodError do
      redirect_to order_path(@order), flash: { error: I18n.t('snd.errors.invalid_payment_method') }
    end

    rescue_from Stripe::InvalidRequestError do
      redirect_to order_path(@order), flash: { error: I18n.t('snd.errors.payment_failed') }
    end

    rescue_from ChargeService::CardError do
      redirect_to order_path(@order), flash: { error: I18n.t('snd.errors.card_error') }
    end
  end
end
