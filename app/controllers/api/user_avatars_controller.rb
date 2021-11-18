# frozen_string_literal: true

module API
  class UserAvatarsController < BaseController
    skip_authorization_check

    def create
      if user_avatar_params[:image].present?
        @user_avatar = User::Avatar.new(user_avatar_params)

        if @user_avatar.save
          render status: 201
        else
          render status: 500, json: { error: 'upload_error' }
        end
      else
        render status: 400, json: { error: 'no_image_file' }
      end
    end

    private

    def user_avatar_params
      params.require(:user_avatar).permit(:image)
    end
  end
end
