# frozen_string_literal: true

class AddTitleToNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :title, :string
  end
end
