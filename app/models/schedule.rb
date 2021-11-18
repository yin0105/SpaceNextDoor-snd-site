# frozen_string_literal: true

class Schedule < ApplicationRecord
  include AASM

  belongs_to :schedulable, polymorphic: true

  enum status: {
    scheduled: 0,
    started: 1,
    completed: 2,
    cancelled: 3
  }

  scope :due, -> { where(arel_table[:schedule_at].lteq(Time.zone.now)) }
  scope :extend_booking_slot, -> { where(event: :extend_booking_slot) }

  aasm column: :status, enum: true, no_direct_assignment: true do
    state :scheduled, initial: true
    state :started, :completed, :cancelled

    event :start do
      transitions from: :scheduled, to: :started
    end

    event :finish do
      transitions from: :started, to: :completed
    end

    event :cancel do
      transitions from: :scheduled, to: :cancelled
    end
  end

  def perform
    return unless scheduled?

    start!
    ScheduleJob.perform_later(self)
  end
end
