# frozen_string_literal: true

class VerificationCode < ApplicationRecord
  class ExpiryVerificationCode; end

  self.inheritance_column = :_type

  CODE_KEEP_LENGTH = 5.minutes
  CODE_DIGIT = 6

  belongs_to :user

  enum type: {
    phone: 1
  }

  validates :type, :code, :expiry_at, presence: true

  before_validation -> { setup_verification_code }, on: :create
  after_create -> { dispatch_verification_code }

  def active?
    !expiry?
  end

  def expiry?
    Time.zone.now > expiry_at
  end

  def verify
    return if expiry?

    case type
    when 'phone' then user.confirm_phone
    end

    self[:expiry_at] = Time.zone.now
    save
  end

  def self.latest(type)
    where(type: type).order(expiry_at: :asc).last
  end

  private

  def setup_verification_code
    self[:code] = random_code
    self[:expiry_at] = CODE_KEEP_LENGTH.from_now
  end

  def random_code(digit = CODE_DIGIT)
    Array.new(digit).map { SecureRandom.random_number(0..9) }.join
  end

  def dispatch_verification_code
    case type
    when 'phone'
      SmsService.new.send_out(to: user.unconfirmed_phone, body: I18n.t('snd.users.phone_verification_message', code: code))
    end
  end
end
