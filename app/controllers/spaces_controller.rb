# frozen_string_literal: true

class SpacesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    redirect_if_needed
    load_spaces
    authorize_resource
  end

  def show
    load_space
    load_evaluations
    authorize_resource
  end

  private

  def redirect_if_needed
    redirect_to searches_path(search_params.to_h.symbolize_keys) if params.fetch(:search, nil)
  end

  def load_spaces
    @spaces ||= searches.activated.includes(:address).includes(:images)
    @spaces = @spaces.page(params[:page]).per(12)
    recommend_spaces if @spaces.count.zero?
  end

  def recommend_spaces
    @recommended_spaces = SpaceRecommendService.new(search_params).start!
  end

  def load_evaluations
    @evaluations ||= @space.evaluations.completed.includes(:user).page(params[:page])
  end

  def load_space
    @space ||= space_scope.or(user_space_scope).find(params[:id])
  end

  def space_scope
    Space.activated
  end

  def user_space_scope
    user_signed_in? ? Space.not_deleted.where(user: current_user) : Space.none
  end
end
