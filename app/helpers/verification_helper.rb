# frozen_string_literal: true

module VerificationHelper
  def active_verification_code?(type: :phone)
    current_user.verification_codes.latest(type)&.active?
  end
end
