# frozen_string_literal: true

class CreateBookingSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :booking_slots do |t|
      t.references :space, foreign_key: true
      t.date :date
      t.boolean :booked, default: false

      t.timestamps
    end
  end
end
