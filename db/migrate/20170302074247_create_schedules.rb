# frozen_string_literal: true

class CreateSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :schedules do |t|
      t.integer :schedulable_id
      t.string :schedulable_type
      t.string :event
      t.integer :status
      t.datetime :schedule_at

      t.timestamps
    end

    add_index :schedules, %i[status schedule_at]
    add_index :schedules, %i[schedulable_id schedulable_type]
  end
end
