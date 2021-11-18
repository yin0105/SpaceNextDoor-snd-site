# frozen_string_literal: true

class BlankArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :not_array) unless value.is_a?(Array)

    record.errors.add(attribute, :blank) if value.compact.empty?
  end
end
