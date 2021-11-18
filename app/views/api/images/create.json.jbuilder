# frozen_string_literal: true

json.image do
  json.extract! @image, :id, :url, :thumb_url
end
