# frozen_string_literal: true

module Insurance
  INSURANCE = YAML.load_file(Rails.root.join('config', 'insurance.yml'))

  MINIAL_INSURANCE_TYPE = INSURANCE['minial_insurance_type']

  NULL_INSURANCE_TYPE = INSURANCE['null_insurance_type']

  INSURANCE_TYPES = INSURANCE['insurance_types']

  INSURANCE_OPTIONS = INSURANCE_TYPES.reject do |k, _v|
    NULL_INSURANCE_TYPE.include?(k)
  end

  class << self
    def insurance_type(type)
      INSURANCE_TYPES[type]
    end

    def insurance_coverage(type)
      INSURANCE_TYPES[type]['coverage']
    end

    def insurance_cost(type)
      INSURANCE_TYPES[type]['cost']
    end

    def premium(type = MINIAL_INSURANCE_TYPE)
      INSURANCE_TYPES[type]['premium']
    end

    def insurance_attributes(insurance_enable, insurance_type)
      type = get_sanitized_insurance_type(insurance_enable, insurance_type)
      premium = Money.new(premium(type))

      {
        insurance_enable: insurance_enable,
        insurance_type: type,
        premium: premium
      }
    end

    private

    def get_sanitized_insurance_type(insurance_enable, insurance_type)
      if insurance_enable
        if INSURANCE_TYPES.key?(insurance_type)
          insurance_type
        else
          MINIAL_INSURANCE_TYPE
        end
      else
        NULL_INSURANCE_TYPE
      end
    end
  end
end
