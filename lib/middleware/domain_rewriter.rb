# frozen_string_literal: true

class DomainRewriter
  def initialize(app)
    @app = app
  end

  def redirect(location)
    [301, { 'Location' => location, 'Content-Type' => 'text/html' }, ['Move Permanently']]
  end

  def call(env)
    request = Rack::Request.new(env)
    return redirect(build_new_url(request)) if rewrite_required?(request)

    @app.call(env)
  end

  private

  def build_new_url(request)
    [request.scheme, '://', Settings.domain.main, request.fullpath].join
  end

  def rewrite_required?(request)
    Settings.domain.main != request.host
  end
end
