# frozen_string_literal: true

module RSpec
  module UserHelper
    def login(user = nil)
      user ||= FactoryBot.create(:user)

      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    def logout
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_out
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::UserHelper, type: :controller
end
