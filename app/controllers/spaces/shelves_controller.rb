# frozen_string_literal: true

module Spaces
  class ShelvesController < ApplicationController
    before_action -> { @space = Space.find(params[:space_id]) }

    def create
      authorize! :show, @space
      @space.show!
      redirect_to user_spaces_path
    end

    def destroy
      authorize! :hide, @space
      @space.hide!
      redirect_to user_spaces_path
    end
  end
end
