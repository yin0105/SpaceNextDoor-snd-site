# frozen_string_literal: true

class Storage
  class Form < ActiveType::Record[Storage]
    include AASM

    enum edit_status: {
      create_step_1: 0,
      create_step_2: 1,
      create_step_3: 2,
      create_step_4: 3,
      create_step_5: 7,
      update_calendar: 4,
      accept_snd_rules: 5,
      submit: 6,
      update: 16,
      update_step_2: 17,
      update_step_3: 18,
      update_step_4: 19,
      update_step_5: 20
    }, _prefix: true

    aasm column: :edit_status, enum: true, no_direct_assignment: true do
      state :create_step_1, initial: true
      state :create_step_2
      state :create_step_3
      state :create_step_4
      state :create_step_5
      state :update_calendar
      state :accept_snd_rules
      state :submit
      state :update
      state :update_step_2
      state :update_step_3
      state :update_step_4
      state :update_step_5

      event :next_step do
        transitions from: :create_step_1,    to: :create_step_2,    guard: :draft?
        transitions from: :create_step_2,    to: :create_step_3,    guard: :draft?
        transitions from: :create_step_3,    to: :accept_snd_rules, guard: :draft?
        transitions from: :accept_snd_rules, to: :create_step_4,    guard: :draft?
        transitions from: :create_step_4,    to: :create_step_5,    guard: :draft?
        transitions from: :create_step_5,    to: :update_calendar,  guard: :draft?
        transitions from: :update_calendar,  to: :submit,           guard: :draft?
        transitions from: :submit,           to: :update

        transitions from: :update,           to: :update_step_2
        transitions from: :update_step_2,    to: :update_step_3
        transitions from: :update_step_3,    to: :update_step_4
        transitions from: :update_step_4,    to: :update_step_5
        transitions from: :update_step_5,    to: :update_calendar
        transitions from: :update_calendar,  to: :update
      end

      event :prev_step do
        transitions from: :create_step_2,    to: :create_step_1,    guard: :draft?
        transitions from: :create_step_3,    to: :create_step_2,    guard: :draft?
        transitions from: :accept_snd_rules, to: :create_step_3,    guard: :draft?
        transitions from: :create_step_4,    to: :accept_snd_rules, guard: :draft?
        transitions from: :create_step_5,    to: :create_step_4, guard: :draft?
        transitions from: :update_calendar,  to: :create_step_5,    guard: :draft?
        transitions from: :submit,           to: :update_calendar,  guard: :draft?

        transitions from: :update_step_2,    to: :update
        transitions from: :update_step_3,    to: :update_step_2
        transitions from: :update_step_4,    to: :update_step_3
        transitions from: :update_step_5,    to: :update_step_4
        transitions from: :update_calendar,  to: :update_step_5
      end

      event :edit_promotion do
        transitions from: :update,           to: :update_step_5
        transitions from: :update_step_2,    to: :update_step_5
        transitions from: :update_step_3,    to: :update_step_5
        transitions from: :update_step_4,    to: :update_step_5
        transitions from: :update_calendar,  to: :update_step_5
        transitions from: :update_step_5,    to: :update_step_5
      end
    end

    delegate :draft?, :activated?, to: :space, prefix: true

    def becomes_form
      class_names = [
        "storage/as_#{edit_status}".camelize,
        "storage/as_#{edit_status.gsub(/_step.+$/, '')}".camelize
      ]

      becomes(class_names.find do |class_name|
        class_name.constantize
              rescue NameError
                nil
      end&.constantize)
    end
  end
end
