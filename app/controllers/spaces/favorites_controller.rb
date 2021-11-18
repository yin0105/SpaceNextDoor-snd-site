# frozen_string_literal: true

module Spaces
  class FavoritesController < ApplicationController
    skip_authorization_check

    def create
      build_favorite
      save_favorite
    end

    def destroy
      load_favorite
      destroy_favorite
    end

    private

    def save_favorite
      @favorite.save! if @favorite.new_record?

      if @favorite.errors.empty?
        flash[:success] = I18n.t('snd.success.create_user_favorite_space_relation_succeeded')
      else
        flash[:error] = I18n.t('snd.failure.create_user_favorite_space_relation_failed')
      end

      redirect_to user_spaces_path
    end

    def current_space
      @space ||= Space.find_by(id: params[:space_id].to_i)
    end

    def build_favorite
      @favorite ||= favorite_scope.where(
        user: current_user,
        space: current_space
      ).first_or_initialize
    end

    def load_favorite
      @favorite ||= favorite_scope.find_by(user: current_user, space: current_space)
    end

    def destroy_favorite
      if @favorite.destroy
        flash[:success] = I18n.t('snd.success.remove_user_favorite_space_relation_succeeded')
      else
        flash[:error] = I18n.t('snd.failure.remove_user_favorite_space_relation_failed')
      end

      redirect_to user_spaces_path
    end

    def favorite_scope
      User::FavoriteSpaceRelation
    end
  end
end
