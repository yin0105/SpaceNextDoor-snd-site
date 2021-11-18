# frozen_string_literal: true

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w[jpg jpeg gif png]
  end

  process :store_dimensions

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  version :slide do
    process resize: 'x1080^'
    process resize_and_pad: [1920, 1080]
  end

  version :cover do
    process resize_to_fill: [640, 360]
  end

  version :thumb do
    process resize_to_fill: [400, 400]
  end

  private

  def store_dimensions
    return unless file && model

    model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
  end

  def secure_token
    model.secure_token ||= SecureRandom.hex(32)
  end

  def resize(size)
    manipulate! do |image|
      image.resize size
    end
  end
end
