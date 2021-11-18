# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :searches

  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_error

  check_authorization unless: :no_authorization_controller?
  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!, unless: :no_authorization_controller?

  def current_host
    @current_host ||= User::Host.find_by(id: current_user.id)
  end

  def current_guest
    @current_guest ||= User::Guest.find_by(id: current_user.id)
  end

  def authorize_resource
    CanCan::ControllerResource.new(self).authorize_resource
  end

  protected

  def search_params
    params.fetch(:search, params).permit(:region, :price, :type, :size, :check_in, :check_out, :user_latitude, :user_longitude, :hide_map, :sort, :promotion)
  end

  def searches
    @search ||= Search.new(search_params)
  end

  def admin_controller?
    is_a?(ActiveAdmin::Devise::SessionsController) || is_a?(ActiveAdmin::BaseController)
  end

  def no_authorization_controller?
    devise_controller? || admin_controller?
  end

  def user_for_paper_trail
    if admin_controller?
      current_admin.present? ? "Admin##{current_admin.id}" : nil
    else
      current_user.present? ? "User##{current_user.id}" : nil
    end
  end

  def info_for_paper_trail
    { request_id: request.request_id }
  end

  def devise_parameter_sanitizer
    case resource_class.to_s
    when 'User'
      User::ParameterSanitizer.new(User, :user, params)
    else
      super
    end
  end

  def handle_csrf_error
    render json: { error: 'InvalidAuthenticityToken' }, status: 401
  end
end
