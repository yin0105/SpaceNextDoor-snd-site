# frozen_string_literal: true

class User
  class PaymentMethod < ApplicationRecord
    self.inheritance_column = :_type

    # constants
    TYPES = {
      stripe: 0
    }.freeze

    belongs_to :user

    enum type: TYPES

    validates :type, :identifier, :expiry_date, :token, presence: true
  end
end
