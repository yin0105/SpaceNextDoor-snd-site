# frozen_string_literal: true

module Ratable
  extend ActiveSupport::Concern

  included do
    has_many :evaluations, as: :ratable, class_name: '::Rating'
  end

  def rate_score
    evaluations.completed.average(:rate).to_f.round(1)
  end
end
