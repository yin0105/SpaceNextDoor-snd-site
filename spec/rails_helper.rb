# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter "/vendor/"
end

require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'webdrivers/chromedriver'
# Add additional requires below this line. Rails is not loaded until this point!
require "money-rails/test_helpers"
require 'sidekiq/testing'
require 'faker'
require 'aasm/rspec'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'devise'

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--headless')
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.javascript_driver = :chrome
Capybara.current_driver = :chrome

Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{example.description.tr(' ', '-').gsub(%r{^.*\/spec\/}, '')}"
end

Capybara::Screenshot.prune_strategy = :keep_last_run

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseRewinder.clean_all
  end

  config.before(:all) do
    DatabaseRewinder.clean_all
  end

  config.after(:each, js: false) do
    DatabaseRewinder.clean
  end

  config.after do
    Warden.test_reset!
  end

  config.append_after do
    Capybara.reset_sessions!
  end

  config.around(:each, js: true) do |example|
    ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
    example.run
    ActiveRecord::Base.shared_connection = nil
  end

  config.around(:each, js: true) do |example|
    DatabaseRewinder.cleaning do
      example.run
    end
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers

  DoubleEntry::Locking.configuration.running_inside_transactional_fixtures = true
end
