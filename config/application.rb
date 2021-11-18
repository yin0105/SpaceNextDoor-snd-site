# frozen_string_literal: true

require_relative 'boot'
require_relative '../lib/middleware/domain_rewriter'
require_relative '../lib/middleware/x_robot_tag'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SND
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.eager_load_paths << Rails.root.join('lib')
    config.assets.paths += [
      Rails.root.join('vendor', 'assets', 'fonts'),
      Rails.root.join('vendor', 'smooth_scroll', 'javascripts')
    ]

    # Require `belongs_to` associations by default. Previous versions had false.
    config.active_record.belongs_to_required_by_default = true

    config.active_job.queue_adapter = :sidekiq

    # rubocop:disable Style/DoubleNegation
    config.middleware.use DomainRewriter if !!ENV['DOMAIN_REWRITE']
    config.middleware.use XRobotTag unless Rails.env.production?

    # display singapore local time
    config.time_zone = 'Asia/Singapore'
  end
end
