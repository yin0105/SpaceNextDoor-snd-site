# frozen_string_literal: true

class Rating < ApplicationRecord
  include AASM

  # constants
  STATUS = { pending: 0, completed: 1 }.freeze
  IDENTITY = %w[guest host].freeze

  paginates_per 6
  enum status: STATUS

  # relationships
  belongs_to :ratable, polymorphic: true
  belongs_to :user
  belongs_to :order

  # scope
  scope :by_host, -> { where(rater_type: :host) }
  scope :by_guest, -> { where(rater_type: :guest) }

  # callbacks
  before_validation :set_rater_type, on: :create
  before_save :change_status_if_needed

  # validations
  validates :rate, inclusion: { in: 0..5 }, if: -> { rate.present? }
  validate :validate_rater_type

  # aasm
  aasm column: :status, enum: true, no_direct_assignment: true do
    state :pending, initial: true
    state :completed

    event :complete do
      transitions from: :pending, to: :completed
    end
  end

  private

  def set_rater_type
    self.rater_type = user&.identity&.to_s
  end

  def validate_rater_type
    return if IDENTITY.include?(rater_type)

    errors.add(:rater_type, 'wrong identity')
  end

  def change_status_if_needed
    complete if !completed? && rate.present?
  end
end
