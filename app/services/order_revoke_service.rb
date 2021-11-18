# frozen_string_literal: true

class OrderRevokeService
  class NotRevocableError < RuntimeError; end

  def initialize(order)
    @order = order
  end

  def start!
    raise NotRevocableError unless @order.pending?

    @order.long_term_cancelled_at = Time.zone.now if @order.long_term?
    @order.revoke!
  end
end
