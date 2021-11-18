# frozen_string_literal: true

module Identifiable
  extend ActiveSupport::Concern

  def identity
    self.class.name.demodulize.downcase
  end
end
