# frozen_string_literal: true

class DatepickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    value = object.send(attribute_name)
    value = object.send(attribute_name).join('; ') if options[:mode] == :multiple

    merged_input_options = merge_wrapper_options(input_html_options.merge(data: config, value: options[:value] || value), wrapper_options)
    @builder.text_field(attribute_name, merged_input_options)
  end

  def enable_dates(dates = nil)
    return dates.flatten.join(';') if dates

    nil
  end

  def disable_dates(dates = nil)
    return dates.flatten.join(';') if dates

    nil
  end

  def config
    # return if object_long_lease?
    data = { datepicker: true }

    data[:mode] = options[:mode] if %i[single multiple range].include?(options[:mode])
    data[:inline] = options[:inline] || false
    data[:min_date] = options[:min_date]

    # NOTE: flatten range may be slow
    data[:enables] = enable_dates(options[:enable])
    data[:disables] = disable_dates(options[:disable])

    data[:between] = options[:between] || nil
    data
  end

  def object_long_lease?
    object.class.name.include?('Order') && object.long_lease?
  end
end
