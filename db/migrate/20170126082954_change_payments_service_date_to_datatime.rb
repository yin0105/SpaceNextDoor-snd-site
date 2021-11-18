# frozen_string_literal: true

class ChangePaymentsServiceDateToDatatime < ActiveRecord::Migration[5.0]
  def change
    change_column :payments, :service_start_at, :datetime
    change_column :payments, :service_end_at, :datetime
  end
end
