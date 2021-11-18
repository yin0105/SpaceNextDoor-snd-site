# frozen_string_literal: true

class TransformLongLeaseForm
  include ActiveModel::Model

  attr_reader :order

  def initialize(order)
    @order = order
  end
end
