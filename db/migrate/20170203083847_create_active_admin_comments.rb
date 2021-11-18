# frozen_string_literal: true

class CreateActiveAdminComments < ActiveRecord::Migration[5.0]
  def self.up
    create_table :active_admin_comments do |t|
      t.string :namespace
      t.text   :body
      t.string :resource_id,   null: false
      t.string :resource_type, null: false
      t.references :author, polymorphic: true
      t.timestamps null: true
    end
    add_index :active_admin_comments, [:namespace]
    add_index :active_admin_comments, %i[resource_type resource_id]
  end

  def self.down
    drop_table :active_admin_comments
  end
end
