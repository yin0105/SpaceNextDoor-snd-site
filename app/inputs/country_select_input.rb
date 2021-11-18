# frozen_string_literal: true

class CountrySelectInput < SimpleForm::Inputs::Base
  def input
    @builder.select(attribute_name, Regions::COUNTRY_ENUM_KEYS)
  end
end
