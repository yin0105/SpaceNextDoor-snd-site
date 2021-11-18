# frozen_string_literal: true

module Schedulable
  class InvalidScheduleError < RuntimeError; end
  class ScheduleNotFound < RuntimeError; end
  class MissingModelIdError < RuntimeError; end

  extend ActiveSupport::Concern

  included do
    has_many :schedules, as: :schedulable

    def schedule(name, at:)
      action = self.class.schedules[name.to_sym]

      raise ScheduleNotFound if action.nil?
      raise MissingModelIdError if new_record?

      schedules.create(schedulable: self, event: name, schedule_at: at)
    end

    def perform_schedule(name)
      action = self.class.schedules[name.to_sym]

      raise ScheduleNotFound if action.nil?

      send(action)
    end
  end

  class_methods do
    @schedule_mappings = {}

    def schedules
      @schedule_mappings ||= {}
    end

    def schedule(name, action = nil, &block)
      raise InvalidScheduleError unless action.present? || block_given?

      callback = block || action
      action = "_schedule_#{name}" if action.is_a?(Proc)
      define_method action, &callback if callback.is_a?(Proc)
      schedules[name] = action.to_sym
    end
  end
end
