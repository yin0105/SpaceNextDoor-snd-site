# frozen_string_literal: true

class LateFeeRentPayoutJob < ApplicationJob
  queue_as :default

  def perform(late_fee_payment)
    LateFeeRentPayoutService.new(late_fee_payment).start!
  end
end
