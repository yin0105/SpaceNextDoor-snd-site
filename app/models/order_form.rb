# frozen_string_literal: true

class OrderForm
  include ActiveModel::Model

  class MinimumRentDaysError < RuntimeError; end
  class DiscountOneMonthRequireDaysError < RuntimeError; end
  class DiscountTwoMonthsRequireDaysError < RuntimeError; end

  attr_accessor :start_at, :long_term, :term, :error_messages, :insurance_type
  attr_reader :order, :end_at, :discount_code

  validates :start_at, :end_at, presence: true
  validates :discount_code, if: -> { @discount_code.present? }, numericality: { only_integer: true }
  validates :term, acceptance: true

  def initialize(order, space)
    @order = order
    @space = space
  end

  def discount_code=(code)
    return if code.blank?

    @discount_code = code.to_i
  end

  def end_at=(date)
    if discount_code.nil?
      return @end_at = @long_term.present? ? Time.zone.parse(@start_at) + Order::INTERVAL.days : date
    end

    @end_at = date
  end

  def attributes
    {
      start_at: @start_at,
      end_at: @end_at,
      discount_code: @discount_code,
      long_term: @long_term,
      term: @term,
      rent_payout_type: @space.rent_payout_type
    }.merge(
      Insurance.insurance_attributes(@space.insurance_enable, @insurance_type)
    )
  end

  def promotion_avaliable?
    card_info = @order.guest.as_user.payment_method
    return false if card_info.blank?

    card_info.expiry_date > @end_at.to_date
  end

  def save
    update_order_attributes

    if valid?
      persist
    else
      add_term_blank_error if term_checked_error?

      false
    end
  end

  def update_order_attributes
    @order.assign_attributes(attributes) if @space
  end

  private

  def persist
    return false if @space.blank?
    return true if @order.save

    errors.messages.merge!(@order.errors.messages)
    raise_order_error

    false
  end

  def raise_order_error
    raise DiscountOneMonthRequireDaysError if discount_one_month_needed_days_error?
    raise DiscountTwoMonthsRequireDaysError if discount_two_months_needed_days_error?
    raise MinimumRentDaysError if minimum_days_error?
  end

  def add_term_blank_error
    @error_messages = I18n.t('custom_error_msgs.orders.term_blank_full')
  end

  def term_checked_error?
    errors.messages[:term].present?
  end

  def discount_one_month_needed_days_error?
    errors.messages[:discount_code].first&.include?('90')
  end

  def discount_two_months_needed_days_error?
    errors.messages[:discount_code].first&.include?('180')
  end

  def minimum_days_error?
    errors.messages[:days].present?
  end
end
