# frozen_string_literal: true

class ExtendSlotJob < ApplicationJob
  queue_as :default

  def perform(space)
    ExtendBookingSlotService.new(space).start!
  end
end
