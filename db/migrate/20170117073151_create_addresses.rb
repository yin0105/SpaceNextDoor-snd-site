# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :addressable_type, limit: 32
      t.integer :addressable_id
      t.string :country, limit: 8
      t.string :city, limit: 16
      t.string :area, limit: 16
      t.string :street_address
      t.string :unit
      t.float :latitude
      t.float :longitude

      t.timestamps
    end

    add_index :addresses, :addressable_type
    add_index :addresses, :addressable_id
    add_index :addresses, :country
    add_index :addresses, :city
    add_index :addresses, :area
    add_index :addresses, %i[latitude longitude]
  end
end
