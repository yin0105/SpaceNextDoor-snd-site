# frozen_string_literal: true

class Channel < ApplicationRecord
  # TODO: change table name

  belongs_to :guest, class_name: 'User::Guest'
  belongs_to :host, class_name: 'User::Host'
  belongs_to :space
  has_many :messages, -> { order(created_at: :desc) }
  has_many :orders
  accepts_nested_attributes_for :orders

  validate :validate_identity

  default_scope -> { order(updated_at: :desc) }
  scope :with_messages, -> { joins(:messages).distinct(:channel) }

  delegate :name, to: :space, prefix: true

  # callbacks
  before_validation(on: :create) do
    self.host_id = space&.user&.id
  end

  def unrated_orders
    orders.completed.reject(&:receive_all_ratings?)
  end

  def pending_order?
    orders.pending.any?
  end

  def create_system_message(start_at, end_at)
    messages.create!(
      user: guest.as_user,
      is_system: true,
      content: I18n.t('channel.message.system',
                      name: guest.name,
                      start_at: I18n.l(start_at, format: :normal_inverse),
                      end_at: I18n.l(end_at, format: :normal_inverse))
    )
  end

  private

  def validate_identity
    return if host.nil? || guest.id != host.id

    errors.add(:guest, :host_cannot_open_a_channel_with_himself)
  end
end
