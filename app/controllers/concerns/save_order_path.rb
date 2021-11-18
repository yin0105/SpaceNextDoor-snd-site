# frozen_string_literal: true

module SaveOrderPath
  extend ActiveSupport::Concern

  included do
    before_action :save_order_path, only: [:show]
  end

  private

  def save_order_path
    referer = URI(request.referer || '')
    return unless referer.path == new_order_path

    session[:last_order_path] = referer.request_uri
  end

  def saved_order_path
    path = session[:last_order_path]
    session[:last_order_path] = nil
    path
  end
end
