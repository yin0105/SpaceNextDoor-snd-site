# frozen_string_literal: true

module Imageable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :imageable
    accepts_nested_attributes_for :images, allow_destroy: true
  end

  def assign_attributes(new_attributes)
    unless new_attributes.respond_to?(:stringify_keys)
      raise ArgumentError, 'When assigning attributes, you must pass a hash as an argument.'
    end
    return if new_attributes.blank?

    assign_images_by_attributes(new_attributes[:images_attributes])

    super(new_attributes)
  end

  private

  def assign_images_by_attributes(images_attributes)
    return if images_attributes.blank?

    image_ids = images_attributes.map { |_k, v| v[:id] } || []

    if id.present?
      new_images = Image.where(imageable_id: nil, id: image_ids)
      new_images.update(imageable: self)
      images.concat(new_images)
    else
      self.images = Image.where(imageable_id: nil, id: image_ids)
    end
  end
end
