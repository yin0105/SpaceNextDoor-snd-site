# frozen_string_literal: true

module Users
  module Profile
    class PasswordsController < ApplicationController
      skip_authorization_check

      def edit
        @user = current_user
      end

      def update
        @user = User.find(current_user.id)

        if @user.update_with_password(user_params)
          bypass_sign_in(@user)
          redirect_to edit_profile_password_path, flash: { success: I18n.t('devise.passwords.updated_not_active') }
        else
          render 'edit'
        end
      end

      private

      def user_params
        params.require(:user).permit(:password, :password_confirmation, :current_password)
      end
    end
  end
end
