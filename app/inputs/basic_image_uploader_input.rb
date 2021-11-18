# frozen_string_literal: true

class BasicImageUploaderInput < SimpleForm::Inputs::Base
  include Rails.application.routes.url_helpers

  # rubocop:disable Rails/OutputSafety
  def input(_wrapper_options = nil)
    thumb_size = options[:thumb_size] || 'thumb'
    object.try("build_#{attribute_name}") if object.try(attribute_name).blank?
    image_model = object.try(attribute_name)
    image_model_name = image_model.class.name.underscore.tr('/', '_')

    template.content_tag :div, class: 'basic-image-uploader-input', data: {
      upload_api_path: try("api_#{image_model_name.pluralize}_path"),
      image_model_name: image_model_name
    } do
      template.concat <<-EOF.strip_heredoc.html_safe
        <div class="preview-area">
          <div class="image-thumbnail">
            <a href="#{image_model&.image&.url}" target="_blank">
              <img src="#{image_model&.image&.try(thumb_size)&.url}" />
            </a>
          </div>
        </div>
      EOF

      template.concat <<-EOF.strip_heredoc.html_safe
        <div class="upload-area">
          <div class="add-image">
            Upload
            <input
              type=\"file\"
              accept=\"image/jpg,image/jpeg,image/gif,image/png\"
              form=""
              data-upload-input="ture"
            >
          </div>
        </div>
      EOF

      template.concat @builder.hidden_field "belonging_#{attribute_name}_id", data: { uploader: :id_input }
    end
  end
end
