# frozen_string_literal: true

class CreateMessage < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.references :user
      t.references :chanel, foreign_key: { to_table: :order_chanels }
      t.text :content
      t.boolean :read_yet, default: false
      t.timestamps
    end
  end
end
