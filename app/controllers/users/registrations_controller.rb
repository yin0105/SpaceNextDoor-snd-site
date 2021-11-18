# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include HostEditInfoFlow

    respond_to :json, :html

    def edit
      set_identity
      render :edit
    end

    protected

    def after_sign_up_path_for(resource)
      stored_location_for(resource) || signup_success_path
    end

    def update_resource(resource, params)
      if params.key?(:password)
        super
      else
        resource.update_without_password(params)
      end
    end

    def after_update_path_for(_resource)
      return host_next_edit_flow_path if is_host?(params[:user][:identity])

      edit_user_registration_path
    end

    def set_identity
      @identity = params[:identity]
    end
  end
end
