# frozen_string_literal: true

class User
  class VerificationForm < ActiveType::Record[User]
    def phone
      original_phone = self[:phone] || unconfirmed_phone
      GlobalPhone.parse(original_phone)&.international_format || original_phone
    end
  end
end
