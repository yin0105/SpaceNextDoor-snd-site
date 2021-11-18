# frozen_string_literal: true

class OrdersMailerPreview < ActionMailer::Preview
  def activating
    OrdersMailer.activating(Order.first)
  end

  def cancellation_notice_given_for_guest
    OrdersMailer.cancellation_notice_given_for_guest(Order.where.not(long_term_cancelled_at: nil).first)
  end

  def cancellation_notice_given_for_host
    OrdersMailer.cancellation_notice_given_for_host(Order.where.not(long_term_cancelled_at: nil).first)
  end

  def insurance_will_changed_next_period
    OrdersMailer.insurance_will_changed_next_period(Order.active.where.not(insurance_type: Insurance::NULL_INSURANCE_TYPE).order('updated_at desc').first)
  end

  def transform_long_lease
    OrdersMailer.transform_long_lease(Order.where.not(long_term_start_at: nil).first)
  end
end
