# frozen_string_literal: true

class Image < ApplicationRecord
  mount_uploader :image, ImageUploader

  scope :valid, -> { where.not(image: nil) }

  belongs_to :imageable, polymorphic: true, optional: true

  delegate :url, to: :image, allow_nil: true

  def thumb_url
    image.thumb.url
  end
end
