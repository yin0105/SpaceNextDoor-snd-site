# frozen_string_literal: true

class RatingsController < ApplicationController
  def update
    build_rating
    authorize_resource
    save_rating
  end

  private

  def build_rating
    @rating ||= current_user.ratings.find_by(id: params[:id])
    @rating.attributes = rating_params
  end

  def save_rating
    if @rating.save
      redirect_back(fallback_location: channels_path)
    else
      render template: 'channels/show'
    end
  end

  def rating_params
    params.require(:rating).permit(:rate, :note)
  end
end
