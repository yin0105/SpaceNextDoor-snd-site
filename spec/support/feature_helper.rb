# frozen_string_literal: true

module RSpec
  module FeatureHelper
    include Warden::Test::Helpers

    def self.included(base)
      base.before { Warden.test_mode! }
      base.after { Warden.test_reset! }
    end

    def sign_in(resource)
      login_as(resource, scope: warden_scope(resource))
    end

    def sign_out(resource)
      logout(warden_scope(resource))
    end

    private

    def warden_scope(resource)
      resource.class.name.underscore.to_sym
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::FeatureHelper, type: :feature
  config.include RSpec::FeatureHelper, type: :request
end
