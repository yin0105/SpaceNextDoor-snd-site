# frozen_string_literal: true

class Message < ApplicationRecord
  include Imageable

  # constants
  ALARMING_WORDING = '[FILTERED]'
  # constant which means if create_at is smaller than x minutes ago, it is outdated
  THRESHOLD = 5

  # relationships
  belongs_to :user
  belongs_to :channel, touch: true

  # validations
  validate :validate_user

  # scope
  default_scope { order(id: :desc) }
  scope :unread, -> { where(read_at: nil) }
  scope :sent_by, ->(user) { where(user_id: user.id) }
  scope :sent_to, ->(user) { where.not(user_id: user.id) }
  scope :latest, -> { order(created_at: :desc) }

  # callbacks
  before_save :remove_email
  before_save :remove_phone
  after_create :send_notification

  def target_user
    if user_id == channel.host_id
      channel.guest.as_user
    else
      channel.host.as_user
    end
  end

  # the latest message which the same user send
  def latest?
    self.class.sent_by(user).first.id == id
  end

  def sent_by_system?
    is_system
  end

  private

  def validate_user
    # TODO: I18n
    return if errors.any?
    return if [channel.guest_id, channel.host_id].include?(user.id)

    errors.add(:channel_id, "user doesn't belongs_to the channel")
  end

  def remove_email
    self.content = content.gsub(/[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+/, ALARMING_WORDING)
  end

  def remove_phone
    self.content = content.gsub(/((\+\d{2}|\(+\d{2}\)+)[\s-]*)?(\d{4}[\s-]*\d{4,11})/, ALARMING_WORDING)
  end

  def send_notification
    return if is_system

    MessageJob.set(wait: THRESHOLD.minutes, retry: false).perform_later(self)
  end
end
