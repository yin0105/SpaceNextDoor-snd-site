# frozen_string_literal: true

class Space
  module PublicApi
    extend ActiveSupport::Concern

    def dates
      booking_slots.reject(&:disabled?).map(&:date)
    end

    def available_dates(start_at: Time.zone.now, end_at: Float::INFINITY)
      booking_slots.available.between(start_at..end_at).pluck(:date)
    end

    def dates=(slots)
      @dates = slots
      change_format
      mark_booking_slots
      build_booking_slots
    end

    def featured_image
      images.last
    end

    def featured_image_url(size: nil)
      featured_image.image_url(size)
    end

    def discounted?
      discount_code.present?
    end

    def is_available?
      booking_slots.available.where('date >= ?', Time.zone.now.to_date).size > 1
    end

    def activated_order
      orders
        .active
        .where('start_at <= ? AND end_at >= ?', Time.zone.now.to_date, Time.zone.now.to_date)&.first
    end

    def order_taking_record(date)
      orders
        .where(status: %i[pending active])
        .where('start_at > ?', date)
    end

    def last_valid_order_end_at
      last_valid_order&.long_term_cancelled_at || last_valid_order&.end_at
    end

    def last_valid_order_date
      last_valid_order_end_at || created_at.to_date
    end

    def vacant_days
      (Time.zone.now.to_date - last_valid_order_date).to_i
    end

    def insurance?
      return false if property == 'residential' && status_before_active?
      return true if status_before_active?

      insurance_enable?
    end

    def status_before_active?
      pending? || draft? || disapproved?
    end

    def has_active_long_lease_order?
      orders.active.where(long_term: true).any?
    end

    def display_name
      "[#{id}] #{name}"
    end

    private

    def change_format
      @dates = case @dates
               when String
                 @dates.split(';').reject(&:blank?).map { |date| Date.parse(date) }
               when Range
                 @dates.to_a
               else
                 @dates
               end

      @dates.map!(&:to_date) if @dates.any? && @dates.first.class != Date
    end

    def build_booking_slots
      return unless @dates.any?

      status = has_active_long_lease_order? ? :booked : :available
      (@dates - booking_slots.map(&:date)).each do |date|
        booking_slots.build(date: date, status: status)
      end
    end

    def unselect_dates
      valid_dates = dates.select { |date| date >= Time.zone.today }
      unselect_dates = (valid_dates - @dates)
      unselect_dates.reject { |date| date > (Time.zone.today + 11.months).at_end_of_month }
    end

    def mark_booking_slots
      return if @dates.empty? || booking_slots.empty?

      # rubocop:disable Rails/SkipsModelValidations
      booking_slots.disabled.where(date: @dates).update_all(status: :available)
      booking_slots.available.where(date: unselect_dates).update_all(status: :disabled)
    end
  end
end
