# frozen_string_literal: true

class XRobotTag
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    headers['X-Robots-Tag'] = 'noindex, nofollow' unless Rails.env.production?

    [status, headers, response]
  end
end
