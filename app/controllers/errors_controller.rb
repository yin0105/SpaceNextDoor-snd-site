# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check
  protect_from_forgery except: :route_not_found

  def route_not_found
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: 404, layout: false }
      format.json { render json: { status: 404, message: 'Page Not Found' } }
      format.any { render plain: 'File not found', status: 404 }
    end
  end
end
