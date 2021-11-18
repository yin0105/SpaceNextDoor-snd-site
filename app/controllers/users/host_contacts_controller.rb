# frozen_string_literal: true

module Users
  class HostContactsController < ApplicationController
    include CommonContact
    include HostEditInfoFlow

    skip_authorization_check

    private

    def current_role
      current_host
    end

    def save_contact
      @contact.assign_attributes(contact_params)
      if @contact.save
        redirect_to success_redirect_path
      else
        render :new
      end
    end

    def success_redirect_path
      return host_next_edit_flow_path if is_host?(params[:contact][:identity])

      host_contact_url
    end
  end
end
