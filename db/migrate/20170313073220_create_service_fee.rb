# frozen_string_literal: true

class CreateServiceFee < ActiveRecord::Migration[5.0]
  def change
    create_table :service_fees do |t|
      t.float :host_rate
      t.float :guest_rate
      t.references :order, foreign_key: true
    end
  end
end
