# frozen_string_literal: true

class Order
  module SlotsUpdate
    extend ActiveSupport::Concern

    def book_slots(service_start = nil)
      service_start ||= start_at
      return update_corresponding_booking_slots(service_start + LONGEST_YEAR.years - 1) if long_term

      update_corresponding_booking_slots
    end

    def unbook_slots
      return update_corresponding_unbooking_slots(long_term_cancelled_at + 1, long_term_cancelled_at + LONGEST_YEAR.years - 1) if long_term

      update_corresponding_unbooking_slots
    end

    private

    def update_corresponding_booking_slots(service_end = nil)
      # rubocop:disable Rails/SkipsModelValidations
      service_end ||= end_at
      space.booking_slots.available.where(date: start_at..service_end).update_all(status: :booked)
    end

    def update_corresponding_unbooking_slots(service_start = nil, service_end = nil)
      service_start ||= last_payment.service_start_at
      service_end ||= end_at
      space.booking_slots.where(date: service_start..service_end).booked.update_all(status: :available)
    end
  end
end
