# frozen_string_literal: true

class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :invalid_phone) unless GlobalPhone.validate(value)
  end
end
