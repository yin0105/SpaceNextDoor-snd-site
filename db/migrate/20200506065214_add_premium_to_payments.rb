# frozen_string_literal: true

class AddPremiumToPayments < ActiveRecord::Migration[5.2]
  def change
    add_monetize :payments, :premium
  end
end
