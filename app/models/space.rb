# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Space < ApplicationRecord
  include Imageable
  include Notifiable
  include HasAddress
  include Ratable
  include AASM
  include Schedulable

  PROPERTY = {
    residential: 0,
    commercial: 1,
    industrial: 2
  }.freeze

  RENT_PAYOUT_TYPE = {
    one_month: 1,
    ten_days: 2
  }.freeze

  paginates_per 6
  has_paper_trail
  acts_as_geolocated lat: 'latitude', lng: 'longitude', through: :address

  schedule :extend_booking_slot, -> { ExtendSlotJob.perform_later(self) }

  belongs_to :spaceable, polymorphic: true, optional: true
  belongs_to :user, optional: false
  has_many :orders
  has_many :favorite_space_relations, class_name: 'User::FavoriteSpaceRelation'
  has_many :eager_users, through: :favorite_space_relations, source: :user
  has_many :booking_slots, autosave: true
  has_one :last_valid_order, -> { valid.order(created_at: :desc) }, class_name: 'Order'

  enum status: {
    draft: 0,
    pending: 1,
    activated: 2,
    deactivated: 3,
    soft_deleted: 4,
    disapproved: 5
  }

  enum discount_code: {
    one_month: 1,
    two_months: 2,
    one_and_two_months: 3,
    six_months: 4,
    one_and_six_months: 5,
    two_and_six_months: 6,
    one_two_and_six_months: 7
  }

  enum rent_payout_type: RENT_PAYOUT_TYPE, _suffix: true

  enum property: PROPERTY

  default_scope { order(featured: :desc, created_at: :desc) }

  scope :available_in, ->(range) { joins(:booking_slots).where(booking_slots: { status: :available, date: range }).distinct(:id) }
  scope :not_available_in, ->(range) { joins(:booking_slots).where(booking_slots: { date: range }).where.not(booking_slots: { status: :available }).distinct(:id) }

  scope :submitted, -> { where(status: %i[pending activated deactivated]) }
  scope :not_deleted, -> { where.not(status: :soft_deleted) }

  before_save -> { self.daily_price = Money.new(daily_price_cents) }
  after_save :extend_booking_slots

  monetize :daily_price_cents

  aasm column: :status, enum: true do
    state :draft, initial: true
    state :pending, :activated, :deactivated, :soft_deleted, :disapproved

    event :submit do
      transitions from: :draft, to: :pending, after: :notify_after_submit
    end

    event :approve, after_commit: %i[notify_after_approve setup_insurance] do
      transitions from: :pending, to: :activated
    end

    event :disapprove, after_commit: [:notify_after_disapprove] do
      transitions from: :pending, to: :disapproved
    end

    event(:hide) { transitions from: :activated, to: :deactivated }
    event(:show) { transitions from: :deactivated, to: :activated }
    event(:soft_delete) { transitions from: %i[draft activated deactivated], to: :soft_deleted }
  end

  validates :area, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }
  validates :height, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :status, presence: true

  include Space::PublicApi

  def self.build_up_area
    sum(:area)
  end

  def self.available_area
    available_in(Time.current..(Time.current + 1.day)).sum(:area)
  end

  def self.occupied_area
    joins(:orders).where(orders: { status: :active }).sum(:area)
  end

  def self.available_by_area(area)
    available_in(Time.current..(Time.current + 1.day)).joins(:address).where(addresses: { area: area }).count
  end

  def self.booked_by_area(area)
    not_available_in(Time.current..(Time.current + 1.day)).joins(:address).where(addresses: { area: area }).count
  end

  private

  def notify_after_submit
    send_notification(action: :submission, resource: self)
  end

  def notify_after_approve
    send_notification(action: :approval, resource: self)
  end

  def notify_after_disapprove
    send_notification(action: :disapproval, resource: self)
  end

  def validate_dates
    return if (@dates || []).reject { |date| date >= Time.zone.today }.blank?

    errors.add(:dates, :cannot_add_the_date_in_the_past)
  end

  def extend_booking_slots
    return ExtendBookingSlotService.new(self).start! if auto_extend_slot?

    CancelExtendSlotService.new(self).start!
  end

  def setup_insurance
    update(insurance_enable: property != 'residential')
  end
end
# rubocop:enable Metrics/ClassLength
