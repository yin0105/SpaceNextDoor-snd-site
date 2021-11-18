# frozen_string_literal: true

class User
  class Avatar < ApplicationRecord
    mount_uploader :image, UserAvatarUploader

    belongs_to :user, optional: true

    delegate :url, :small, :medium, to: :image, allow_nil: true

    def thumb_url
      image.small.url
    end
  end
end
