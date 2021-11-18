# frozen_string_literal: true

require 'sidekiq-scheduler'

class ScheduleWorker
  include Sidekiq::Worker

  def perform
    Schedule.due.scheduled.each(&:perform)
  end
end
