# frozen_string_literal: true

class TransformLongLeaseService
  def initialize(order, transform_by)
    @order = order
    @transform_by = transform_by
  end

  def start!
    return unless @order.transformable_long_term?

    update_order
    update_booking_slots
    cancel_order_schedule
    create_payment
    notify_users
  end

  def transformable_long_term?
    return false if @order.long_term?
    return false unless @order.active?
    return false unless @order.started?
    return false unless Time.zone.today < @order.end_at
    return false unless @order.booking_slots_available_long_lease?
    return false if @order.booking_taken?

    true
  end

  private

  def cancel_order_schedule
    order_schedules = @order.schedules.scheduled
    order_schedules.each(&:cancel!)
  end

  def update_order
    attributes = {
      type: 'instalment',
      long_term: true,
      long_term_start_at: @order.transform_long_term_booking_dates.first,
      end_at: @order.transform_long_term_booking_dates.last,
      total_payment_cycle: 4,
      remain_payment_cycle: 3,
      transform_long_lease_by: @transform_by
    }
    @order.update(attributes)
  end

  def update_booking_slots
    @order.book_slots(@order.long_term_start_at)
  end

  def schedule_long_term_payment
    @order.schedule(:payment, at: @order.long_term_start_at)
  end

  def create_payment
    CreatePaymentService.new(@order).start!
  end

  def notify_users
    @order.send_notification(action: :transform_long_lease_for_guest, resource: @order)
    @order.send_notification(action: :transform_long_lease_for_host, resource: @order)
  end
end
