# frozen_string_literal: true

class OrderFullCancelScheduleService
  def initialize(order)
    @order = order
  end

  def start!
    return unless @order.last_payment.pre_cancel?

    cancel_all_order_schedules
    cancel_all_payment_schedules
  end

  private

  def cancel_all_order_schedules
    order_schedules = @order.schedules.scheduled
    order_schedules.each(&:cancel!)
  end

  def cancel_all_payment_schedules
    order_payment_schedules = @order.last_payment.schedules.scheduled
    order_payment_schedules.each(&:cancel!)
  end
end
