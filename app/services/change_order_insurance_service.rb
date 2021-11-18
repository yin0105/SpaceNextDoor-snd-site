# frozen_string_literal: true

class ChangeOrderInsuranceService
  def initialize(order, type)
    @order = order
    @space = @order.space
    @insurance_type = type
  end

  def start!
    return unless @order.can_change_insurance?

    update_order
    notify_user
  end

  private

  def update_order
    insurance_attributes = Insurance.insurance_attributes(
      @space.insurance_enable, @insurance_type
    )
    @order.update(insurance_attributes)
  end

  def notify_user
    @order.send_notification(action: :insurance_will_changed_next_period, resource: @order)
  end
end
