# frozen_string_literal: true

class Select2Input < SimpleForm::Inputs::Base
  def input
    @builder.select(attribute_name, options[:collection] || [])
  end
end
