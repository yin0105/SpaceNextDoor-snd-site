# frozen_string_literal: true

class RangeSliderInput < SimpleForm::Inputs::StringInput
  RANGER_PATTERN = /[0-9.]+\.{2,3}[0-9.]+/.freeze
  def input(wrapper_options = nil)
    data = {}

    data[:min], data[:max] = slider_range

    merged_input_options = merge_wrapper_options({ value: value, data: data }, wrapper_options)

    out = ActiveSupport::SafeBuffer.new
    out << @builder.hidden_field(attribute_name, merged_input_options)
    out << safe_join(["<input type='range' class='range-input' multiple value= '#{value.gsub('..', ',')}'>".html_safe])
  end

  def value
    value = object.send(attribute_name)
    return value.to_s if value.is_a?(Range)
    return value if RANGER_PATTERN.match?(value.to_s)

    "0..#{value.to_f}"
  end

  def slider_range
    min = options[:min] || 0
    max = options[:max] || 100

    if options[:range]&.is_a?(Range)
      min = options[:range].min
      max = options[:range].max
    end

    [min, max]
  end
end
