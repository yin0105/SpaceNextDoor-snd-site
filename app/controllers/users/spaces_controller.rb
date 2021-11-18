# frozen_string_literal: true

module Users
  class SpacesController < ApplicationController
    helper_method :search_space
    skip_authorization_check only: [:well_done]

    def index
      load_spaces
      check_required_fields
      authorize_resource
    end

    def edit
      load_space
      authorize_resource
      redirect_to [:edit, :user, @space.spaceable, edit_promotion: params[:edit_promotion]]
    end

    def well_done
      load_space
    end

    def query_spaces
      load_spaces

      @spaces = @spaces.order(id: :asc).limit(30).map do |space|
        { id: space.id, text: space.display_name }
      end
      authorize_resource
      render status: 200, json: @spaces
    end

    protected

    def search_space
      @search ||= User::SearchSpace.new(search_params)
    end

    private

    def load_spaces
      @spaces ||= if params[:identity] == 'guest'
                    current_user.favorite_spaces
                  else
                    current_user.spaces.submitted
                  end
      query_with_condition
      @spaces = @spaces.includes(:address).page(params[:page])
    end

    def check_required_fields
      @required_fields = []
    end

    def query_with_condition
      query_with_region
      query_with_field
    end

    def query_with_region
      if search_params[:region].present?
        @spaces = @spaces.joins(:address).where(addresses: { id: Address.in(search_params[:region]).pluck(:id) })
      end
    end

    def query_with_field
      return if search_params[:field].blank?

      @spaces = if action_name.to_s == 'index'
                  if search_params[:field].present?
                    @spaces.where(id: search_params[:field])
                  end
                else
                  @spaces.where('lower(name) like ?', "%#{search_params[:field].downcase}%").or(@spaces.where(id: search_params[:field]))
                end
    end

    def load_space
      @space ||= current_user.spaces.find(params[:id])
    end

    def search_params
      params.fetch(:user_search_space, params).permit(:region, :field)
    end
  end
end
