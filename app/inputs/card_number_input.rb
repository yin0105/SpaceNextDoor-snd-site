# frozen_string_literal: true

class CardNumberInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    attribute = {
      data: { 'card-number': true, stripe: 'number' },
      placeholder: '•••• •••• •••• ••••'
    }

    merged_input_options = merge_wrapper_options(attribute, wrapper_options)
    @builder.text_field(attribute_name, merged_input_options)
  end
end
