# frozen_string_literal: true

class AddIndexToStatusInBookingSlots < ActiveRecord::Migration[5.0]
  def change
    add_index :booking_slots, :status
  end
end
