# frozen_string_literal: true

module AdminLog
  def create_action_log(target: resource, event: params[:action], status:)
    Admin::ActionLog.create(
      admin: current_admin,
      target_id: target.id,
      target_type: target.class.to_s,
      status: status,
      event: event.titleize,
      request_id: request.request_id
    )
  end
end
