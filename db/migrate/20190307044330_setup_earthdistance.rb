# frozen_string_literal: true

class SetupEarthdistance < ActiveRecord::Migration[5.0]
  def self.up
    execute 'CREATE EXTENSION IF NOT EXISTS cube'
    execute 'CREATE EXTENSION IF NOT EXISTS earthdistance'
  end

  def self.down
    execute 'DROP EXTENSION IF EXISTS earthdistance'
    execute 'DROP EXTENSION IF EXISTS cube'
  end
end
