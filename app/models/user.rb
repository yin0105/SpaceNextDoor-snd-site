# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

class User < ApplicationRecord
  include HasAddress
  include Ratable
  include Identifiable
  include Notifiable
  include User::Phone # phone, phone_verified?, confirm_phone

  ROLES = %w[host guest].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable,
         omniauth_providers: [:facebook], allow_unconfirmed_access_for: nil

  has_paper_trail

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :phone_confirmed, -> { where.not(phone: nil) }
  scope :phone_unconfirmed, -> { where(phone: nil) }
  scope :all_hosts, -> { joins(:spaces).where(spaces: { status: :activated }).distinct }
  scope :hosts_with_existing_bookings, -> { User::Host.joins(:orders).where(orders: { status: :active }).distinct }
  scope :guests_with_existing_bookings, -> { User::Guest.joins(:orders).where(orders: { status: :active }).distinct }
  scope :assign_users, ->(user_ids) { User.where(id: user_ids) }
  scope :last_week_signed_up, -> { where(created_at: 7.days.ago..Time.current) }
  scope :last_month_signed_up, -> { where(created_at: 1.month.ago..Time.current) }
  scope :last_week_moved_out, -> { joins(:orders).where(orders: { status: :completed, end_at: 7.days.ago..Time.current }, id: no_active_orders) }
  scope :last_month_moved_out, -> { joins(:orders).where(orders: { status: :completed, end_at: 1.month.ago..Time.current }, id: no_active_orders) }

  has_one :avatar
  has_one :payment_method
  has_one :bank_account

  has_many :ratings
  has_many :spaces
  has_many :storages
  has_many :messages
  has_many :favorite_space_relations
  has_many :favorite_spaces, -> { order(updated_at: :desc) }, through: :favorite_space_relations, source: :space
  has_many :notification_relations
  has_many :notifications, through: :notification_relations
  has_many :contacts, class_name: 'Contact', dependent: :destroy

  enum gender: {
    Male: 0,
    Female: 1
  }

  before_validation :nilify_password

  alias :email_verified? confirmed?

  def name
    return email.split('@').first if first_name.nil?

    [first_name, last_name].join(' ')
  end

  def dashboard_display_name
    "[#{id}] #{name}"
  end

  def as_host
    becomes(Host)
  end

  def as_guest
    becomes(Guest)
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.last_name = auth.info&.last_name
      user.first_name = auth.info&.first_name
      user.gender = auth.extra&.raw_info&.gender
    end
  end

  def avatar
    super || build_avatar
  end

  def verified?
    phone_verified?
  end

  def has_guest_contact?
    as_guest.contact&.present?
  end

  def can_book?
    phone_verified? && payment_method.present? && has_guest_contact?
  end

  def unread_notification?
    return false if last_notification.blank?
    return true if notifications_seen_at.nil?

    last_notification.created_at >= notifications_seen_at
  end

  def last_notification
    Notification.where(notify_type: 0).or(Notification.where(id: notifications.ids)).last
  end

  def unread_message?(type)
    channel_scope = case type
                    when :any
                      Channel.where(host_id: id).or(Channel.where(guest_id: id))
                    when :host
                      Channel.where(host_id: id)
                    else
                      Channel.where(guest_id: id)
                    end
    channel_scope.joins(:messages).where(messages: { read_at: nil }).where.not(messages: { user_id: id }).limit(1).any?
  end

  private

  def after_confirmation
    send_notification(action: :sign_up_success, resource: self)
  end

  def nilify_password
    self.password = password.presence
    self.password_confirmation = password_confirmation.presence
  end
end
# rubocop:enable Metrics/ClassLength
