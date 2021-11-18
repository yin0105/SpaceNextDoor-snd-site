# frozen_string_literal: true

class Order
  module Service
    extend ActiveSupport::Concern

    def current_payment_cycle
      return total_payment_cycle if remain_payment_cycle.zero?

      total_payment_cycle - remain_payment_cycle
    end

    def next_service_start_at
      return end_at.end_of_day if remain_payment_cycle.zero?
      return start_at.beginning_of_day if remain_payment_cycle == total_payment_cycle
      return long_term_start_at.beginning_of_day + ((current_payment_cycle - 1) * INTERVAL).days if long_term_start_at.present?

      start_at.beginning_of_day + (current_payment_cycle * INTERVAL).days
    end

    def next_service_end_at
      return end_at.end_of_day if remain_payment_cycle <= 1

      next_service_start_at.end_of_day + (INTERVAL - 1).days
    end

    def next_service_days
      return days if payoff?

      ((next_service_end_at - next_service_start_at) / 86_400).ceil
    end

    def long_lease_next_service_days
      if last_payment&.last_long_lease_payment?
        return ((long_term_cancelled_at.end_of_day - next_service_start_at) / 86_400).ceil
      end

      INTERVAL
    end

    def can_change_insurance?
      return false if insurance_lock?
      return false unless long_term?
      return true if schedule_payment_date.present?
      return true if pending? || payments.last&.failed? || payments.last&.retry?

      false
    end

    def schedule_payment_date
      schedules.where(event: :payment, status: :scheduled).first&.schedule_at
    end

    def transformable_long_term?
      return false if long_term?
      return false unless active?
      return false unless started?
      return false unless Time.zone.today < end_at
      return false unless booking_slots_available_long_lease?
      return false if booking_taken?

      true
    end

    def booking_taken?
      space.order_taking_record(end_at).present?
    end

    def booking_slots_available_long_lease?
      space.booking_slots.available.between(transform_long_term_booking_dates).count == INTERVAL * 3
    end

    def transform_long_term_booking_dates
      (end_at + 1)..(end_at + INTERVAL * 3)
    end
  end
end
