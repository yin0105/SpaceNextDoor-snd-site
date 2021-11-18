# frozen_string_literal: true

class LeaseEndJob < ApplicationJob
  queue_as :default

  def perform(payment)
    Accounting::LeaseEndService.new(payment).start
    Payout.create!(payment: payment,
                   user: payment.order.host.as_user,
                   type: :rent,
                   start_at: payment.service_start_at,
                   end_at: payment.service_end_at,
                   amount: payment.host_rent)
    # switch monthly payout to weekly payout, schedule at next payout cycle date
    reschedule_rent_payout payment
  end

  def reschedule_rent_payout(payment)
    next_payment = payment.order.last_payment.as_payment
    return if next_payment == payment

    end_schedule = next_payment.schedules.find_by(event: :service_end)
    rent_payout_schedule = next_payment.schedules.find_by(event: :rent_payout)
    end_schedule.cancel! if end_schedule.present?
    next_payment.schedule_rent_payout if rent_payout_schedule.blank?
  end
end
