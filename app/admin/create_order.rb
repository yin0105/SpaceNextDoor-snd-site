# frozen_string_literal: true

ActiveAdmin.register_page 'Create Booking' do
  menu parent: 'Bookings'

  page_action :create_booking, method: :post do
    create_booking
  end

  controller do
    rescue_from ActiveRecord::RecordNotFound, with: :order_info_errors

    def create_booking
      find_user
      find_space
      build_order
      save_order
    end

    def order_info_errors
      redirect_to admin_create_booking_path, flash: { error: 'Create order failed. Please check your information of the order.' }
    end

    private

    def find_user
      @current_user = User::Guest.find(order_params[:guest_id])
    end

    def find_space
      @current_space = Space.find(order_params[:space_id])
    end

    def build_order
      @order = @current_user.orders.build
      @order.space_id = @current_space.id
      @order.start_at = "#{order_params['check_in(1i)']}-#{order_params['check_in(2i)']}-#{order_params['check_in(3i)']}"
      @order.end_at = "#{order_params['check_out(1i)']}-#{order_params['check_out(2i)']}-#{order_params['check_out(3i)']}"
    end

    def save_order
      if @order.save
        create_payment
        redirect_to admin_bookings_path, flash: { success: 'Creating order is successful!' }
      else
        redirect_to admin_create_booking_path, flash: { error: 'Create failed. Please check your information of the order.' }
      end
    end

    def create_payment
      CreatePaymentService.new(@order).start!
    end

    def order_params
      params.require(:order).permit(:space_id, :guest_id, 'check_in(1i)', 'check_in(2i)', 'check_in(3i)',
                                    'check_out(1i)', 'check_out(2i)', 'check_out(3i)')
    end
  end

  content do
    render partial: 'create_booking_form'
  end
end
