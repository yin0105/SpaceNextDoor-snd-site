# frozen_string_literal: true

class AddressInput < SimpleForm::Inputs::StringInput
  def input(_wrapper_options)
    out = ActiveSupport::SafeBuffer.new

    out << '<div class="address-input">'.html_safe

    @builder.simple_fields_for(attribute_name, data: { address_input: true }) do |form|
      object = form.object
      country_value = object.country_before_type_cast
      postal_code_value = object.postal_code_before_type_cast
      city_value = object.city_before_type_cast
      area_value = object.area_before_type_cast
      street_address_value = object.street_address_before_type_cast

      out << form.text_field(:country, value: country_value, data: { address: :country })
      out << form.text_field(:postal_code, value: postal_code_value, placeholder: 'Postal code', data: { address: :postal_code },
                                           class: 'select2-container
                                     form-control select2-selection
                                     select2-selection--single')
      out << form.text_field(:city, value: city_value, data: { address: :city })
      out << form.text_field(:area, value: area_value, data: { address: :area })
      out << form.text_field(
        :street_address,
        value: street_address_value, placeholder: 'Street address',
        data: { address: :street_address }, class: 'form-control'
      )
      out << form.text_field(:unit, placeholder: 'Block and/or Unit number', data: { address: :unit }, class: 'form-control')
    end

    out << '</div>'.html_safe

    out
  end
end
