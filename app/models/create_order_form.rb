# frozen_string_literal: true

class CreateOrderForm < OrderForm
  def attributes
    super.merge(space_id: @space.id)
  end
end
