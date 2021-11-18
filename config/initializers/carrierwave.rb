# frozen_string_literal: true

CarrierWave.configure do |config|
  # TODO: Setup AWS S3 for Staging/Production
  config.storage = :file
  config.enable_processing = false if Rails.env.test?

  if Rails.env.production? || Rails.env.staging?
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Settings.aws.access_key,
      aws_secret_access_key: Settings.aws.secret_key,
      region: ENV['AWS_REGION'] || 'us-east-1'
    }
    config.fog_directory  = Settings.aws.bucket || 'assets.spacenextdoor.com'
    config.fog_attributes = { 'Cache-Control' => "max-age=#{365.days.to_i}" }

    config.asset_host = Settings.asset.host
    config.storage = :fog
  end
end
