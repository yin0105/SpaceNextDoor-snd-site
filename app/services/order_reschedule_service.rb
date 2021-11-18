# frozen_string_literal: true

class OrderRescheduleService
  def initialize(order)
    @order = order
  end

  def start!
    return unless need_to_reschedule?

    @last_schedule_at = @order.long_term_cancelled_at.end_of_day - 1.day
    update_schedule
  end

  private

  def need_to_reschedule?
    return false if @order.long_term_cancelled_at.nil?

    @order.refund_due? || @order.long_term_cancelled_at.to_date == @order.last_payment.service_end_at.to_date
  end

  def update_schedule
    update_service_end_schedule
    update_rent_payout_schedule
    update_payment_schedule
  end

  def update_payment_schedule
    payment_schedule = @order.schedules.where(event: :payment).scheduled.where(' schedule_at > ? ', @order.last_payment.service_start_at).first
    payment_schedule.cancel!
  end

  def update_service_end_schedule
    lease_end_schedule = @order.last_payment.schedules.where(event: 'service_end').first
    return if lease_end_schedule.blank?

    lease_end_schedule.cancel!
    @order.last_payment.as_payment.schedule(:service_end, at: @last_schedule_at)
  end

  def update_rent_payout_schedule
    schedule = @order.last_payment.schedules.where(event: 'rent_payout').scheduled.where('schedule_at > ?', @last_schedule_at).order(id: :asc).last
    return if schedule.blank?

    schedule.cancel!
    @order.last_payment.as_payment.schedule(:rent_payout, at: @last_schedule_at)
  end
end
