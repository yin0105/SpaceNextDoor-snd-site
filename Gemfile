# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.6'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'pg', '~> 0.18'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.4.1'

# Front End
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'jbuilder'
gem 'jquery-fileupload-rails'
gem 'jquery-modal-rails-assets', '~> 0.9.1'
gem 'sassc-rails', '~> 1.3.0'
gem 'select2-rails'
gem 'simple_form'
gem 'slim-rails'
gem 'sprockets', '~> 3.7.1'
gem 'sprockets-commoner'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 3.5'

# Action Cable
# gem 'redis', '~> 4.0'

# Security
gem 'bcrypt', '3.1.13'

# Dashboard
gem 'active_material', git: 'https://github.com/vigetlabs/active_material.git'
gem 'activeadmin'

# Configuration
gem 'settingslogic'

# User Authentication
gem 'devise'
gem 'global_phone'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'twilio-ruby'

# Authorization
gem 'cancancan'

# File Upload
gem 'carrierwave', '~> 1.0.0'
gem 'fog-aws'

# Generate pdf
gem 'wicked_pdf', '2.1.0'
gem 'wkhtmltopdf-binary', '0.12.6.3'

# Form Validation
gem 'recaptcha', '~> 5.4.1'

# Image Processor
gem 'mini_magick', '~> 4.8'

# Geolocation
gem 'geocoder'

# Backing Services
gem 'stripe'

# Accounting
gem 'money-rails'

# Double Entry
gem 'double_entry'

# Utils
gem 'aasm'
gem 'active_type'
gem 'json', '~> 2.0.0'
gem 'kaminari'
gem 'newrelic_rpm'
gem 'paper_trail'
gem 'rollbar'

# Worker
gem 'sidekiq'
gem 'sidekiq-scheduler'

# Mailer
gem 'mjml-rails'

# postgre extend
gem 'activerecord-postgres-earthdistance', '~> 0.7.1'

group :staging, :production do
  gem 'wkhtmltopdf-heroku', '2.12.5.0'
end

group :development, :test, :staging do
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development, :staging do
  # Rails Console Helper
  gem 'awesome_print'
  gem 'hirb'
  gem 'pry'
  gem 'pry-rails'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  gem 'capybara', '>= 2.15', require: false
  gem 'capybara-screenshot', require: false
  gem 'fuubar', require: false
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'simplecov', '~> 0.17.1', require: false
  gem 'webdrivers'

  gem 'dotenv-rails'
  gem 'shoulda', '~>3.5.0'

  gem 'rubocop', '~> 0.81.0', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'scss_lint', '~> 0.53.0', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # Profiling
  gem 'bullet'
  gem 'fast_stack'
  gem 'flamegraph'
  gem 'memory_profiler'
  gem 'meta_request'
  gem 'rack-mini-profiler', git: 'https://github.com/MiniProfiler/rack-mini-profiler'
  gem 'stackprof'

  # Test Helper
  gem 'guard', require: false
  gem 'guard-rspec', require: false

  # mail
  gem 'letter_opener'

  # deploy
  gem 'capistrano', '3.10.1'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq'
  gem 'capistrano-upload-config'

  gem 'gitlab'
end

group :test do
  gem 'database_rewinder'
  gem 'rspec_junit_formatter'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
