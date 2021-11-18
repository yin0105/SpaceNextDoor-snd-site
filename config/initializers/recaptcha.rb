# frozen_string_literal: true

Recaptcha.configure do |config|
  config.site_key = Settings.google.recaptcha_v3_site_key
  config.secret_key = Settings.google.recaptcha_v3_secret_key
end
