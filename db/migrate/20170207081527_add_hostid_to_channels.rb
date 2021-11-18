# frozen_string_literal: true

class AddHostidToChannels < ActiveRecord::Migration[5.0]
  def change
    add_reference :channels, :host, foreign_key: { to_table: :users }, index: true
  end
end
