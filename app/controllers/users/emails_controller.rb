# frozen_string_literal: true

module Users
  class EmailsController < ApplicationController
    skip_authorization_check

    def create
      current_user.resend_confirmation_instructions
      redirect_back(fallback_location: verification_path)
    end

    def update
      current_user.update(user_params)
      redirect_to verification_path, flash: { notice: 'Confirmation email have been delivered, please follow the instructions to complete updating' }
    end

    private

    def user_params
      params.required(:user).permit(:email)
    end
  end
end
