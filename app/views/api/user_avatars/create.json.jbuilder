# frozen_string_literal: true

json.image do
  json.extract! @user_avatar, :id, :url, :thumb_url
end
