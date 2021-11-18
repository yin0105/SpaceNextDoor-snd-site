# frozen_string_literal: true

class CreateChanels < ActiveRecord::Migration[5.0]
  def change
    create_table :order_chanels do |t|
      t.references :host, foreign_key: { to_table: :users }
      t.references :guest, foreign_key: { to_table: :users }
      t.references :order

      t.timestamps
    end
  end
end
