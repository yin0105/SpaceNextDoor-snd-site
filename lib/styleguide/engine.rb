# frozen_string_literal: true

require 'rack'

module Styleguide
  class Engine < Rails::Engine
    engine_name 'StyleGuide'

    config.middleware.use Rack::Static, urls: ['/', '/js'], root: Rails.root.join('styleguide'), index: 'index.html'
  end
end
