# frozen_string_literal: true

module API
  class ImagesController < BaseController
    skip_authorization_check

    def create
      if image_params[:image].present?
        @image = Image.new(image_params)

        if @image.save
          render status: 201
        else
          render status: 500, json: { error: 'upload_error' }
        end
      else
        render status: 400, json: { error: 'no_image_file' }
      end
    end

    private

    def image_params
      params.require(:image).permit(:image)
    end
  end
end
