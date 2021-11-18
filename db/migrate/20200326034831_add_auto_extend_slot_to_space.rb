# frozen_string_literal: true

class AddAutoExtendSlotToSpace < ActiveRecord::Migration[5.0]
  def change
    add_column :spaces, :auto_extend_slot, :boolean, default: false
  end
end
