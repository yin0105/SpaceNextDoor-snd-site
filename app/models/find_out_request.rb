# frozen_string_literal: true

class FindOutRequest < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :space, optional: true

  validates :name, :size, :location, :phone, :start_at, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :postal_code, :address, presence: true, if: -> { host? }
  validates :phone, phone: true

  after_create -> { FindOutMoreMailer.notify(self).deliver_later }

  IDENTITIES = {
    guest: 0,
    host: 1
  }.freeze

  enum identity: IDENTITIES

  def initialize(attributes)
    attributes[:identity] = IDENTITIES[:guest] if !attributes.nil? && attributes[:identity].present? && (IDENTITIES.keys.exclude? attributes[:identity])
    super
  end

  def dashboard_display_name
    "[#{id}] #{name}"
  end
end
