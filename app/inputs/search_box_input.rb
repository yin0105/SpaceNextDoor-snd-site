# frozen_string_literal: true

class SearchBoxInput < SimpleForm::Inputs::StringInput
  AVAILABLE_MODE = %w[datepicker search].freeze

  def input(wrapper_options = nil)
    data = options[:data] || {}
    data[mode] = mode_value unless mode.nil?

    merged_input_options = merge_wrapper_options(input_html_options.merge(data: data), wrapper_options)
    # rubocop:disable Rails/OutputSafety
    out = ActiveSupport::SafeBuffer.new

    out << '<div class="form-search header__search">'.html_safe
    out << '<label class="search-region">'.html_safe
    out << '<i class="ico ico-search"></i>'.html_safe
    out << '</label>'.html_safe
    out << @builder.text_field(attribute_name, merged_input_options)
    out << "<button class=\"btn btn-primary\" type\"submit\">#{t('shared.search.search')}</button>".html_safe
    out << '</div>'.html_safe
  end

  def mode
    return unless AVAILABLE_MODE.include?(options[:mode].to_s)

    options[:mode]
  end

  def mode_value
    options[mode] || true
  end
end
