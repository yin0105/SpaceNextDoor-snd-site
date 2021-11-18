# frozen_string_literal: true

module Users
  class GuestContactsController < ApplicationController
    include CommonContact
    include SaveOrderPath

    skip_authorization_check

    private

    def current_role
      current_guest
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
      return guest_contact_url if session[:last_order_path].blank?

      saved_order_path
    end
  end
end
