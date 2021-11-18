# frozen_string_literal: true

class AddInsuranceEnableToSpace < ActiveRecord::Migration[5.2]
  def change
    add_column :spaces, :insurance_enable, :boolean, default: true
  end

  def up
    Space.all.in_batches.each do |spaces|
      spaces.each do |space|
        space.update(insurance_enable: false) if space.property == 'residential'
      end
    end
  end
end
