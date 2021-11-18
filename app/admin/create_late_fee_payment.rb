# frozen_string_literal: true

ActiveAdmin.register_page 'Create Extended Booking Charges' do
  menu parent: 'Bookings'

  page_action :create, method: :post do
    create_late_fee_payment
  end

  controller do
    rescue_from ActiveRecord::RecordNotFound, with: :order_info_errors

    def create_late_fee_payment
      find_order
      build_late_fee_payment
      charge
    end

    def order_info_errors
      redirect_to admin_create_extended_booking_charges_path, flash: { error: 'Create late fee failed. order ID not found.' }
    end

    private

    def find_order
      @current_order = Order.find(payment_params[:order_id])
    end

    def build_late_fee_payment
      @late_fee_payment = @current_order.late_fee_payments.build(
        user: @current_order.guest,
        payment_type: current_payment_type,
        identifier: current_payment_method_identifier,
        service_start_at: "#{payment_params['check_in(1i)']}-#{payment_params['check_in(2i)']}-#{payment_params['check_in(3i)']}",
        service_end_at: "#{payment_params['check_out(1i)']}-#{payment_params['check_out(2i)']}-#{payment_params['check_out(3i)']}"
      )
      @late_fee_payment.rent = period_late_fee
      @late_fee_payment
    end

    def charge
      LateFeePaymentService.new(@late_fee_payment).start!
      redirect_to admin_transactions_path, flash: { success: 'Creating Late Fee is successful!' }
    rescue StandardError
      redirect_to admin_create_extended_booking_charges_path, flash: { error: 'Create failed. Please check your information of the order.' }
    end

    def payment_params
      params.require(:late_fee_payment).permit(:order_id, :check_in, :check_out)
    end

    def current_payment_type
      raise InvalidPaymentMethodError if @current_order.guest.payment_method.nil?

      @current_order.guest.payment_method.type
    end

    def current_payment_method_identifier
      @current_order.guest.payment_method.identifier
    end

    def period_late_fee
      @current_order.price * @late_fee_payment.days_rented
    end
  end

  content do
    render partial: 'create_form'
  end
end
