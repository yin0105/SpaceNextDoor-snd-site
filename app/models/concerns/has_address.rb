# frozen_string_literal: true

module HasAddress
  extend ActiveSupport::Concern

  included do
    has_one :address, as: :addressable
    accepts_nested_attributes_for :address, update_only: true
    validate :validate_valid_address

    delegate :position, :location, to: :address
  end

  def address(auto_build: true)
    return super() unless auto_build

    super() || build_address
  end

  private

  def validate_valid_address
    return if address(auto_build: false).blank?

    # TODO: Use I18n to translate it
    errors.add(:address, 'Is not valid.') unless address.valid?
  end
end
