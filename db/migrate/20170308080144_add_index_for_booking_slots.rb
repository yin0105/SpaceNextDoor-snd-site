# frozen_string_literal: true

class AddIndexForBookingSlots < ActiveRecord::Migration[5.0]
  def change
    add_index :booking_slots, [:booked]
    add_index :booking_slots, %i[date booked]
  end
end
