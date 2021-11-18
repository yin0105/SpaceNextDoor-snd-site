# frozen_string_literal: true

module Users
  class RatingsController < ApplicationController
    def index
      @ratings = current_user.evaluations.completed.where(rater_type: rater_type).page(params[:page])
      authorize_resource
    end

    private

    def rater_type
      params.fetch(:identity, :guest).to_sym == :host ? :guest : :host
    end
  end
end
