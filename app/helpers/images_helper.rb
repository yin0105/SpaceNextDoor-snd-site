# frozen_string_literal: true

module ImagesHelper
  def image_thumb_with_link(image)
    link_to image.url, target: '_blank', rel: 'noopener' do
      image_tag(image.url(:thumb))
    end
  end
end
