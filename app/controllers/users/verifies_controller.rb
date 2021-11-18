# frozen_string_literal: true

module Users
  class VerifiesController < ApplicationController
    include HostEditInfoFlow

    skip_authorization_check
    before_action :load_verification_code

    def create
      result = if @verification&.verify
                 { path: success_redirect_path }
               else
                 { error: { message: 'Verify failed' } }
               end
      respond_to do |format|
        format.json { render json: result }
      end
    end

    private

    def load_verification_code
      @verification = current_user.verification_codes.find_by(type: params[:type], code: params[:code])
    end

    def success_redirect_path
      return host_next_edit_flow_path if is_host?(params[:identity])
      return verification_path if session[:last_order_path].blank?

      path = session[:last_order_path]
      session[:last_order_path] = nil
      path
    end
  end
end
