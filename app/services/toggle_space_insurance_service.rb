# frozen_string_literal: true

class ToggleSpaceInsuranceService
  def initialize(space)
    @space = space
    @orders = @space.orders.valid.includes(:host, :guest).where(status: %w[pending active])
  end

  def start!
    ActiveRecord::Base.transaction do
      update_attribute
      change_orders_insurance
    end
  end

  private

  def update_attribute
    @space.update(insurance_enable: !@space.insurance_enable)
  end

  def change_orders_insurance
    return if @orders.blank?

    @orders.each do |order|
      ChangeOrderInsuranceService.new(order, nil).start!
    end
  end
end
