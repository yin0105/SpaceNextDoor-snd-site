# frozen_string_literal: true

module Users
  class PreferredPhonesController < ApplicationController
    skip_authorization_check

    def show
      @user = current_user
    end

    def update
      @user = current_user

      parsed_phone = GlobalPhone.parse(user_params[:preferred_phone])&.international_format ||
                     user_params[:preferred_phone]

      if check_phone_present && @user.update(preferred_phone: parsed_phone.presence)
        redirect_to preferred_phone_path, flash: { success: 'Preferred Phone is updated!' }
      else
        render 'show'
      end
    end

    private

    def user_params
      params.require(:user).permit(:preferred_phone)
    end

    def check_phone_present
      return true if @user.phone.present?

      @user.errors.add(:preferred_phone, :phone_blank)
      false
    end
  end
end
