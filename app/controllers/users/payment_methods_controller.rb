# frozen_string_literal: true

module Users
  class PaymentMethodsController < ApplicationController
    include SaveOrderPath

    skip_authorization_check
    rescue_from Stripe::InvalidRequestError do
      flash[:error] = I18n.t('snd.errors.payment_service_has_error')
      render json: { path: new_payment_method_path }, status: 400
    end

    rescue_from Stripe::CardError do |error_message|
      flash[:error] = error_message
      render json: { path: new_payment_method_path }, status: 402
    end

    def show; end

    def new; end

    def create
      @payment_method = current_user.payment_method || current_user.build_payment_method(type: :stripe)
      if @payment_method.update(payment_method_params)
        render json: { path: success_redirect_path }
      else
        flash[:error] = I18n.t('snd.errors.create_payment_method_failed')
        render json: { path: new_payment_method_path }, status: 500
      end
    end

    private

    def payment_method_params
      { identifier: params[:identifier],
        token: create_stripe_custom_token(params[:token])['id'],
        expiry_date: params[:expiry_date] }
    end

    def create_stripe_custom_token(token)
      Stripe::Customer.create(
        email: current_user.email,
        source: token
      )
    end

    def success_redirect_path
      return payment_method_path if session[:last_order_path].blank?

      saved_order_path
    end
  end
end
