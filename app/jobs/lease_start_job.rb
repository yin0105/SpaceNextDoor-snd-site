# frozen_string_literal: true

class LeaseStartJob < ApplicationJob
  queue_as :default

  def perform(payment)
    Accounting::LeaseStartService.new(payment).start
  end
end
