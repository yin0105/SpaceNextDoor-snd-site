# frozen_string_literal: true

class BankAccount < ApplicationRecord
  belongs_to :user

  enum country: Regions::COUNTRY_ENUM_KEYS

  validates :user, :country, :bank_code, :account_name, :account_number, :bank_name, :branch_code, presence: true
  validates :bank_code, length: { maximum: 6 }
  validates :account_name, length: { maximum: 32 }
  validates :account_number, length: { maximum: 64 }
  validates :bank_name, length: { maximum: 50 }
  validates :branch_code, length: { maximum: 6 }

  validate :validate_immutable

  private

  def validate_immutable
    return unless persisted? && changed?

    errors.add(:base, :immutable)
  end
end
