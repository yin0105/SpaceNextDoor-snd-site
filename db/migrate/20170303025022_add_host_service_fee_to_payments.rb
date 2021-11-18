# frozen_string_literal: true

class AddHostServiceFeeToPayments < ActiveRecord::Migration[5.0]
  def change
    add_monetize :payments, :host_service_fee
  end
end
