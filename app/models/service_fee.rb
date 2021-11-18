# frozen_string_literal: true

class ServiceFee < ApplicationRecord
  belongs_to :order, optional: true

  validates :host_rate, :guest_rate, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }
end
