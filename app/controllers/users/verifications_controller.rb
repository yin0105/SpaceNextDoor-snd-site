# frozen_string_literal: true

module Users
  class VerificationsController < ApplicationController
    include SaveOrderPath

    skip_authorization_check

    def show
      load_user
    end

    def create
      build_user
      save_user
    end

    private

    def load_user
      @user ||= current_user.becomes(User::VerificationForm)
    end

    alias build_user load_user

    def save_user
      if @user.update(user_params)
        create_phone_verification
        redirect_back(fallback_location: verification_path)
      else
        render :show
      end
    end

    def user_params
      params.required(:user).permit(:phone)
    end

    def create_phone_verification
      @user.verification_codes.create!(type: :phone) unless @user.unconfirmed_phone.nil?
    end
  end
end
