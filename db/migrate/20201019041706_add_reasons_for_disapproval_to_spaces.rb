# frozen_string_literal: true

class AddReasonsForDisapprovalToSpaces < ActiveRecord::Migration[5.2]
  def change
    add_column :spaces, :reasons_for_disapproval, :text
  end
end
