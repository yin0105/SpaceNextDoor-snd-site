# frozen_string_literal: true

module Orders
  class LongLeasesController < ApplicationController
    def destroy
      load_order
      authorize! :update, @order

      return flash_check_out_date_error if check_out_date.nil?
      return flash_discount_needed_days_error unless OrderDiscountEarlyEndableService.new(@order, params).endable?
      return flash_long_lease_transformed_terminate_error unless long_lease_transformed_terminallable?

      CancelLongLeaseService.new(@order, check_out_date).start!
      redirect_to orders_path, notice: I18n.t('controllers.orders.cancel_long_lease')
    end

    private

    def check_out_date
      @check_out_date ||= params[:early_check_out] && Date.parse(params[:early_check_out])
    end

    def load_order
      @order ||= order_scope.includes(:space, payments: [:user]).find(params[:order_id])
    end

    def order_scope
      %w[create new update].include?(action_name.to_s) ? current_guest.direct_orders : current_user_by_identity.orders
    end

    def current_user_by_identity
      identity = params.fetch(:identity, :guest)
      identity = :guest unless User::ROLES.include?(identity.to_s)
      send("current_#{identity}")
    end

    def long_lease_transformed_terminallable?
      return true if @order.long_term_start_at.blank?
      return false unless check_out_date.to_date >= @order.long_term_start_at

      true
    end

    def flash_check_out_date_error
      flash.now[:error] = 'Please entry valid termination date.'

      render template: 'orders/cancel_long_lease'
    end

    def flash_discount_needed_days_error
      flash.now[:error] = "The first available date is #{OrderDiscountEarlyEndableService.new(@order, params).begin_of_endable_date.to_s(:long)}"

      render template: 'orders/cancel_long_lease'
    end

    def flash_long_lease_transformed_terminate_error
      flash.now[:error] = 'Not a available date.'

      render template: 'orders/cancel_long_lease'
    end
  end
end
