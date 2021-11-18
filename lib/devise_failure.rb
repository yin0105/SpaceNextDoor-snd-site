# frozen_string_literal: true

class DeviseFailure < Devise::FailureApp
  def redirect_url
    return scope_url if scope.to_s == 'admin'

    flash.alert = params[:msg] if params[:msg]

    if params[:unauthenticated_path].present?
      redirect_host = URI(params[:unauthenticated_path]).host

      return params[:unauthenticated_path] if redirect_host.nil? || redirect_host == request.host
    end

    root_path
  end

  def respond
    if http_auth?
      http_auth
    else
      flash[:unauthenticated] = true
      redirect
    end
  end
end
