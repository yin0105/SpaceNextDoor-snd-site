# frozen_string_literal: true

class User
  module Phone
    extend ActiveSupport::Concern

    included do
      # relationships
      has_many :verification_codes

      # validations
      validates :phone, :unconfirmed_phone, :preferred_phone, phone: true
      validate :phone_verification_available
    end

    def phone
      GlobalPhone.parse(self[:phone])&.international_format || self[:phone]
    end

    def preferred_phone
      GlobalPhone.parse(self[:preferred_phone])&.international_format || self[:preferred_phone]
    end

    def phone=(phone)
      latest_phone = GlobalPhone.parse(phone)&.international_format
      return if latest_phone == self[:phone]

      self[:unconfirmed_phone] = latest_phone
    end

    def phone_verified?
      self[:phone].present?
    end

    def confirm_phone
      self[:phone] = self[:unconfirmed_phone]
      self[:unconfirmed_phone] = nil
      save(validate: false)
    end

    def display_phone
      preferred_phone || phone
    end

    private

    def phone_verification_available
      return if unconfirmed_phone.nil?

      latest_code = verification_codes.latest(:phone)
      return if latest_code.nil?

      errors.add(:phone, :reconfirm_too_fast) unless latest_code.expiry?
    end
  end
end
