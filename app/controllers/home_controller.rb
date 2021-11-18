# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  FIRST_SPACE = 4
  OTHER_SPACES = [28, 108, 148, 191, 300].freeze

  def index
    @first_space = Space.find_by(id: FIRST_SPACE)
    @other_speces = Space.where(id: OTHER_SPACES)
  end
end
