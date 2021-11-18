# frozen_string_literal: true

class RenameChanelAsChannel < ActiveRecord::Migration[5.0]
  def change
    rename_table :chanels, :channels

    remove_index :messages, :chanel_id
    remove_column :messages, :chanel_id, :integer

    remove_index :orders, :chanel_id
    remove_column :orders, :chanel_id, :integer

    add_reference :messages, :channel
    add_reference :orders, :channel
  end
end
