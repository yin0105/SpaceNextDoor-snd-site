# frozen_string_literal: true

class UserAvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w[jpg jpeg gif png]
  end

  def filename
    "avatar.#{file.extension}" if original_filename.present?
  end

  version :small do
    process resize_to_fill: [80, 80]
  end

  version :medium do
    process resize_to_fill: [320, 320]
  end

  def default_url
    size = case version_name
           when :small
             80
           when :medium
             320
           end

    hash = Digest::MD5.hexdigest(model.user&.email)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end
end
