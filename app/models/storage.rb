# frozen_string_literal: true

class Storage < ApplicationRecord
  CHECKIN_TIMES = {
    office_hours: 0,
    appointment: 1
  }.freeze

  CATEGORY = {
    personal: 0,
    business: 1,
    wine: 2
  }.freeze

  scope :draft, -> { joins(:space).where('spaces.status = ?', Space.statuses[:draft]) }

  belongs_to :user
  has_one :space, as: :spaceable, dependent: :destroy, required: true, autosave: true

  delegate :status, :draft?, :pending?, :activated?, :deactivated?, :soft_deleted?, to: :space, prefix: false

  accepts_nested_attributes_for :space

  enum checkin_time: CHECKIN_TIMES,
       category: CATEGORY

  before_save -> { %i[features facilities rules].each { |attribute| self[attribute].compact! } }
end
