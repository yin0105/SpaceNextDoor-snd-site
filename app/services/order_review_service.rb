# frozen_string_literal: true

class OrderReviewService
  class NotReviewableError < RuntimeError; end

  def initialize(order)
    @order = order
  end

  # only when order is reviewed, it can proceed
  def start!
    raise NotReviewableError unless @order.reviewable_by_admin?

    DoubleEntry.lock_accounts(*Accounting::OrderReviewService.new(@order).lock_accounts) do
      @order.review!
    end
  end
end
