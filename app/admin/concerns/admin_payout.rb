# frozen_string_literal: true

module AdminPayout
  def self.included(base)
    base.send(:member_action, :pay, method: :patch) do
      ConfirmService.new(resource, params[:actual_paid_at]).pay!
      create_action_log(status: :succeed)
      flash[:notice] = 'Marked as paid'
      head :ok
    end

    base.send(:actions, :index, :show, :update)
    base.send(:filter, :user_id, label: 'User ID')
    base.send(:filter, :status, as: :select, collection: Payout.statuses)
    base.send(:filter, :service_start_at_filter, as: :date_range)
  end
end
