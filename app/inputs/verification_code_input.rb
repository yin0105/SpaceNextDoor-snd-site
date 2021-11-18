# frozen_string_literal: true

class VerificationCodeInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    data = { verification: options[:type] || :phone }

    out = ActiveSupport::SafeBuffer.new

    merged_input_options = merge_wrapper_options({ data: data }, wrapper_options)
    @builder.simple_fields_for(attribute_name) do |_|
      out << template.text_field_tag(attribute_name, nil, merged_input_options)
      out << template.button_tag(:verify, type: :button, class: 'profile-verification__form-button button bg-white ml-2', disabled: true)
    end
  end
end
