# frozen_string_literal: true

class BookingSlot < ApplicationRecord
  ONE_MONTH = 30.days

  STATUS = { available: 0, booked: 1, disabled: 2 }.freeze
  enum status: STATUS

  belongs_to :space

  default_scope -> { order(date: :asc) }
  scope :between, ->(range) { where(date: range) }
  scope :available_in_days, lambda { |days|
    where('date BETWEEN ? AND ?',
          Time.zone.now.to_date, Time.zone.now.to_date + (days - 1.day)).where(status: :available)
  }

  delegate :to_s, to: :date

  validates :date, uniqueness: { scope: :space_id }
end
