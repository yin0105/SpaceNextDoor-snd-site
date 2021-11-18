# frozen_string_literal: true

class CancelLongLeaseService
  def initialize(order, check_out_date)
    @order = order
    @check_out_date = check_out_date
  end

  def start!
    update_order_attributes
    schedule_cancellation
    OrderRescheduleService.new(@order).start!
    notify_users
  end

  def schedule_cancellation
    @order.becomes(Order).schedule(:long_lease_end, at: @order.long_term_cancelled_at.end_of_day - 1.day)
  end

  def notify_users
    OrdersMailer.cancellation_notice_given_for_guest(@order).deliver_later
    OrdersMailer.cancellation_notice_given_for_host(@order).deliver_later
    @order.becomes(Order).schedule(:long_lease_before_end, at: @order.long_term_cancelled_at.end_of_day - 7.days)
  end

  def update_order_attributes
    @order.update(cancelled_at: Time.zone.now, long_term_cancelled_at: @check_out_date)
  end
end
