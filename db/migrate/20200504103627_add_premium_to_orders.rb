# frozen_string_literal: true

class AddPremiumToOrders < ActiveRecord::Migration[5.2]
  def change
    add_monetize :orders, :premium
  end
end
