# frozen_string_literal: true

module API
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
  end
end
