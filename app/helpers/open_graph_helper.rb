# frozen_string_literal: true

module OpenGraphHelper
  def og_url
    url_for only_path: false
  end

  def og_image
    content_for(:cover) || image_url('logo_large.png')
  end

  def og_image_width
    content_for(:cover_width) || 600
  end

  def og_image_height
    content_for(:cover_height) || 315
  end
end
