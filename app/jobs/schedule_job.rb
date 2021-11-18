# frozen_string_literal: true

class ScheduleJob < ApplicationJob
  queue_as :schedule

  after_perform do |job|
    job.arguments.first.finish!
  end

  def perform(schedule)
    schedule.schedulable.perform_schedule(schedule.event)
  end
end
