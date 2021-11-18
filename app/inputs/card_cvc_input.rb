# frozen_string_literal: true

class CardCvcInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    attribute = {
      data: { 'card-cvc': true, stripe: 'cvc' },
      placeholder: '•••'
    }

    merged_input_options = merge_wrapper_options(attribute, wrapper_options)
    @builder.text_field(attribute_name, merged_input_options)
  end
end
