# frozen_string_literal: true

class ChangeDamageFeeTypeInOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :damage_fee, :integer
    add_monetize :orders, :damage_fee
  end
end
