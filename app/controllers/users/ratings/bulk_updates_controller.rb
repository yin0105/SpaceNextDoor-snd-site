# frozen_string_literal: true

module Users
  module Ratings
    class BulkUpdatesController < ApplicationController
      skip_authorization_check

      def create
        @form = Rating::MultipleUpdateForm.new
        @form.update(bulk_update_user_ratings_attributes)
        redirect_back fallback_location: root_path, flash: { success: 'Rating has been successfully updated' }
      end

      private

      def bulk_update_user_ratings_attributes
        params.require(:rating_multiple_update_form).permit(ratings_attributes: %i[id rate note])
      end
    end
  end
end
