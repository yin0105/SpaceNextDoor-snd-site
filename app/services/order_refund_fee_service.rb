# frozen_string_literal: true

class OrderRefundFeeService
  class OrderRefundFeeNotMatchPolicyError < RuntimeError; end

  def initialize(payment)
    @payment = payment
  end

  def start
    refund_by_policy!
  end

  private

  def refund_by_policy!
    return early_end_refund_fee if @payment.long_term_early_end?
    return within_one_week_refund_fee if match_one_week_within_cancel_policy?
    return one_week_ago_refund_fee if match_one_week_ago_cancel_policy?
    return two_weeks_ago_refund_fee if match_two_weeks_ago_cancel_policy?

    raise OrderRefundFeeNotMatchPolicyError
  end

  def early_end_refund_fee
    @payment.rent - @payment.days_rented_fee + @payment.service_fee_to_refund
  end

  def within_one_week_refund_fee
    @payment.deposit + @payment.premium
  end

  def one_week_ago_refund_fee
    @payment.amount - (@payment.rent * 0.5) - @payment.guest_service_fee
  end

  def two_weeks_ago_refund_fee
    @payment.amount - @payment.guest_service_fee
  end

  def match_one_week_within_cancel_policy?
    (@payment.service_start_at - 8.days) < order.cancelled_at &&
      order.cancelled_at < @payment.service_start_at
  end

  def match_one_week_ago_cancel_policy?
    (@payment.service_start_at - 15.days) < order.cancelled_at.to_date &&
      order.cancelled_at <= (@payment.service_start_at - 8.days)
  end

  def match_two_weeks_ago_cancel_policy?
    order.cancelled_at <= (@payment.service_start_at - 15.days)
  end

  def order
    @payment.order
  end
end
