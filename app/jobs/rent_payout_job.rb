# frozen_string_literal: true

class RentPayoutJob < ApplicationJob
  queue_as :default

  def perform(payment)
    RentPayoutService.new(payment).start!
  end
end
