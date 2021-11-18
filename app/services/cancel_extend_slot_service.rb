# frozen_string_literal: true

class CancelExtendSlotService
  delegate :empty?, to: :events

  def initialize(space)
    @space = space
  end

  def events
    @space
      .schedules
      .extend_booking_slot
      .scheduled
  end

  def start!
    return if empty?

    events.each(&:cancel!)
  end
end
