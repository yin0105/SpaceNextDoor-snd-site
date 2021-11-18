# frozen_string_literal: true

module IdentityChecking
  extend ActiveSupport::Concern

  private

  def identity(klass)
    @identity ||= klass.exists?(id: params[:id], host_id: current_user.id) ? 'host' : 'guest'
  end
end
