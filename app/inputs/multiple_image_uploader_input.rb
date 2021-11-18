# frozen_string_literal: true

class MultipleImageUploaderInput < SimpleForm::Inputs::Base
  IMAGE_INPUT_FIELD_HTML = <<-EOF.strip_heredoc
    <div class="add-image">
      <i class="fa fa-plus icon"></i>
      <input
        class="input"
        type=\"file\"
        accept=\"image/jpg,image/jpeg,image/gif,image/png\"
        name=\"image[image]\"
        form=""
        data-url=\"#{Rails.application.routes.url_helpers.api_images_path}\"
        data-upload-input="ture"
        multiple
      >
    </div>
  EOF

  # rubocop:disable Metrics/AbcSize
  def input(_wrapper_options)
    # rubocop:disable Rails/OutputSafety
    out = ActiveSupport::SafeBuffer.new

    object_class = @builder.object.class

    length_validator = object_class.validators_on(:images).detect { |v| v.is_a?(ActiveRecord::Validations::LengthValidator) }
    length_validator_options = length_validator.try(:options) || {}

    out << <<-EOF.html_safe
      <div class=\"multiple-image-upload-input\"
        data-object-name=\"#{@builder.object_name}\"
        data-with-description=\"#{options[:with_description]}\"
        data-maximum-length=\"#{length_validator_options[:maximum]}\"
        data-minimum-length=\"#{length_validator_options[:minimum]}\"
        data-length=\"#{@builder.object[:images]&.count || 0}\"
        data-drop-zone-selector=\"#{options[:drop_zone_selector]}\"
      >
    EOF

    out << '<div class="images-wrapper">'.html_safe

    out << '<div class="images" data-images="true">'.html_safe

    @builder.simple_fields_for(:images) do |form|
      out << '<div class="image" data-image-wrapper="true">'.html_safe
      out << "<img src=\"#{form.object.thumb_url}\" />".html_safe
      out << form.hidden_field(:id)
      out << form.hidden_field(:_destroy, data: { destroy_field: true })
      out << '<a class="remove-btn" href="javascript:void(0)" data-remove-btn="true"></a>'.html_safe
      out << form.text_field(:description) if options[:with_description]
      out << '</div>'.html_safe
    end

    out << '</div>'.html_safe

    out << IMAGE_INPUT_FIELD_HTML.html_safe

    out << '</div>'.html_safe

    out << '<div class="drop-zone" data-drop-zone-placeholder="true">DROP IMAGES HERE</div>'.html_safe

    out << '<div class="progress" data-progress="true"><div class="progress-bar progress-bar-striped active"></div></div>'.html_safe

    out << '</div>'.html_safe

    out
  end
end
