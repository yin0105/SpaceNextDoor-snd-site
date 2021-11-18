# frozen_string_literal: true

class AddGuestServiceFeeToPayments < ActiveRecord::Migration[5.0]
  def change
    add_monetize :payments, :guest_service_fee
    rename_column :payments, :amount_cents, :rent_cents
    rename_column :payments, :amount_currency, :rent_currency
  end
end
