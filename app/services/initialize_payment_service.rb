# frozen_string_literal: true

class InitializePaymentService
  class InvalidPaymentMethodError < RuntimeError; end

  def initialize(order)
    @order = order
    @payment = @order.payments.build
  end

  def start!
    assign_serial
    assign_user
    assign_service_period
    assign_type
    assign_identifier
    assign_deposit if @payment.serial == 1
    assign_rent
    assign_service_fee
    assign_premium
    assign_insurance_type

    @payment
  end

  private

  def assign_user
    @payment.user = @order.guest
  end

  def assign_rent
    @payment.rent = if @payment.half_price_discount?
                      next_period_rent / 2
                    else
                      @payment.free_rent_and_service_fee? && 0 || next_period_rent
                    end
  end

  def assign_service_period
    @payment.service_start_at, @payment.service_end_at = next_service_period
  end

  def assign_identifier
    @payment.identifier = current_payment_method_identifier
  end

  def assign_type
    @payment.payment_type = current_payment_type
  end

  def assign_service_fee
    @payment.host_service_fee = @payment.free_rent_and_service_fee? && 0 || (@payment.rent * @order.service_fee_host_rate)
    @payment.guest_service_fee = @payment.free_rent_and_service_fee? && 0 || (@payment.rent * @order.service_fee_guest_rate)
  end

  def assign_serial
    @payment.serial = @order.payments.count + 1
  end

  def assign_deposit
    @payment.deposit = @order.price * Settings.deposit.days
  end

  def assign_premium
    @payment.premium = @order.premium
  end

  def assign_insurance_type
    @payment.insurance_type = @order.insurance_type
  end

  def next_service_period
    return [@order.next_service_start_at, @order.long_term_cancelled_at.end_of_day] if @order.last_long_lease_payment?

    [@order.next_service_start_at, @order.next_service_end_at]
  end

  def next_period_rent
    return @order.price * @order.long_lease_next_service_days if @order.long_term

    @order.price * @order.next_service_days
  end

  def current_payment_type
    raise InvalidPaymentMethodError if @order.guest.payment_method.nil?

    @order.guest.payment_method.type
  end

  def current_payment_method_identifier
    @order.guest.payment_method.identifier
  end
end
