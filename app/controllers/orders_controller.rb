# frozen_string_literal: true

class OrdersController < ApplicationController
  include PaymentErrorHandler
  include OrderErrorHandler

  helper_method :current_space

  def index
    load_orders
    authorize_resource
  end

  def show
    load_order
    authorize_resource
  end

  def new
    redirect_to spaces_path unless current_space
    build_order
    create_order
    authorize_resource
  end

  def create
    current_space
    build_order
    create_order
    authorize_resource
    save_order
  end

  def update
    current_space
    load_current_order
    update_order
    authorize_resource
    save_order
  end

  def edit_insurance
    load_current_order
    redirect_to orders_path unless @order.insurance_enable && @order.can_change_insurance?
    authorize_resource
  end

  def update_insurance
    load_current_order
    ChangeOrderInsuranceService.new(@order, params[:insurance_type]).start!
    redirect_to orders_path
    authorize_resource
  end

  def edit_transform_long_lease
    load_current_order
    redirect_to orders_path unless @order.transformable_long_term?
    @form = TransformLongLeaseByGuestForm.new(@order)
    authorize_resource
  end

  def update_transform_long_lease
    load_current_order
    load_transform_long_lease_service

    @form = TransformLongLeaseByGuestForm.new(@order)
    @form.assign_attributes(term: params[:transform_long_lease_by_guest_form][:term])

    if @form.valid?
      @service.start!
      redirect_to orders_path, flash: { notice: 'Transform long lease success!' }
    else
      flash.now[:error] = @form.error_messages if @form.error_messages.present?
      render :edit_transform_long_lease
    end
    authorize_resource
  end

  def cancel_long_lease
    current_space
    load_current_order
    redirect_to orders_path unless @order.long_term_cancellable?
    authorize_resource
  end

  private

  def load_orders
    @orders ||= order_scope.valid.includes(:space).page(params[:page]).order(id: :desc)
  end

  def load_order
    @order ||= order_scope.includes(:space, payments: [:user]).find(params[:id])
  end

  def load_current_order
    @order ||= order_scope.find(params[:id])
  end

  def build_order
    pending_order = order_scope.pending.find_by(space: current_space, guest: current_guest)
    @order = pending_order || order_scope.build
    # TODO: writing spec for end_at fulfillment
  end

  def create_order
    @form = CreateOrderForm.new(@order, current_space)
    @form.assign_attributes(order_params)
    @form.update_order_attributes
  end

  def update_order
    @form = UpdateOrderForm.new(@order, current_space)
    @form.assign_attributes(order_params)
    @form.update_order_attributes
  end

  def save_order
    if @form.save
      create_payment
      redirect_to well_done_order_payments_path(@form.order)
    else
      flash.now[:error] = @form.error_messages if @form.error_messages.present?
      render :new
    end
  end

  def create_payment
    CreatePaymentService.new(@form.order).start!
  end

  def current_space
    @current_space ||= space_scope.find_by(id: space_id)
  end

  def space_id
    params[:space_id] || params.dig(:order, :space_id)
  end

  def space_scope
    Space.activated
  end

  def order_scope
    %w[create new update].include?(action_name.to_s) ? current_guest.direct_orders : current_user_by_identity.orders
  end

  def current_user_by_identity
    identity = params.fetch(:identity, :guest)
    identity = :guest unless User::ROLES.include?(identity.to_s)
    send("current_#{identity}")
  end

  def order_params
    params.require(:order).permit(:start_at, :end_at, :term, :discount_code, :long_term, :insurance_type)
  end

  def load_transform_long_lease_service
    @service ||= TransformLongLeaseService.new(@order, 'guest')
  end
end
