# frozen_string_literal: true

class StarRatingInput < SimpleForm::Inputs::Base
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    template.content_tag(:div, class: 'star-rating-input', data: { value: @builder.object[attribute_name]&.to_i }) do
      template.concat rating_stars
      template.concat @builder.text_field(attribute_name, merged_input_options)
    end
  end

  def rating_stars
    template.content_tag(:div, class: 'star-rating-input__stars') do
      5.times { |i| template.concat template.content_tag(:span, nil, data: { value: 5 - i }, class: 'fa fa-star-o') }
    end
  end
end
