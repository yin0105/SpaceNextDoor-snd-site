# frozen_string_literal: true

class ChangeBookedColumnToStatusFromBookingSlots < ActiveRecord::Migration[5.0]
  def change
    remove_column :booking_slots, :booked, :boolean, default: false
    add_column :booking_slots, :status, :integer, default: 0
  end
end
