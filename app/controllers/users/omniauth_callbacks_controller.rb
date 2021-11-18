# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_authorization_check

    def facebook
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.facebook_data'] = request.env['omniauth.auth']
        flash[:unauthenticated] = true
        flash[:alert] = I18n.t('devise.registrations.already_signup')
        redirect_to root_path
      end
    end

    def failure
      redirect_to root_path
    end
  end
end
