# frozen_string_literal: true

class ExtendBookingSlotService
  delegate :any?, to: :events

  def initialize(space)
    @space = space
  end

  def start!
    create_booking_slots if extend_slot_now?
    schedule_next_extension
  end

  def events
    @space
      .schedules
      .extend_booking_slot
      .scheduled
  end

  private

  def create_booking_slots
    return create_booked_slots if @space.has_active_long_lease_order?

    create_available_slots
  end

  def create_booked_slots
    extend_dates.each do |date|
      @space.booking_slots.create(date: date, status: :booked)
    end
  end

  def create_available_slots
    extend_dates.each do |date|
      @space.booking_slots.create(date: date, status: :available)
    end
  end

  def schedule_next_extension
    return if any?

    @space.becomes(Space).schedule(:extend_booking_slot, at: next_extend_date.end_of_day)
  end

  def last_slot_date
    return last_slot.date if last_slot.present? && last_slot.date >= Time.zone.today

    Time.zone.today
  end

  def next_extend_date
    last_slot.date - Settings.space.auto_extend_days.days
  end

  def extend_slot_now?
    @space.booking_slots.where('date >= ?', Time.zone.today).size <= Settings.space.auto_extend_days
  end

  def last_slot
    @space.booking_slots.last
  end

  def extend_dates
    ((last_slot_date + 1.day)..(last_slot_date + 1.year))
  end
end
