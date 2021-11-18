# frozen_string_literal: true

class Order
  module PublicApi
    extend ActiveSupport::Concern

    def receive_all_ratings?
      ratings.present? && ratings.pending.empty?
    end

    def days
      return 1 unless end_at && start_at

      (end_at - start_at).to_i + 1
    end

    def amount
      days * price
    end

    def monthly_amount
      30 * space.daily_price
    end

    def monthly_service_fee
      monthly_amount * Settings.service_fee.guest_rate
    end

    def monthly_total
      monthly_amount * 2 + monthly_service_fee + premium
    end

    def monthly_total_without_deposit
      monthly_amount + monthly_service_fee + premium
    end

    def deposit
      return if down_payment.nil?

      down_payment.deposit
    end

    def remain_deposit
      return if deposit.nil?

      deposit - damage_fee
    end

    def identity
      format('%<space_id>s0%<order_id>04d', space_id: space.id.to_s.ljust(4, '0'), order_id: id)
    end

    def long_lease?
      days >= INTERVAL
    end

    def min_rent_days
      space.minimum_rent_days.days
    end

    def notice_days
      Settings.order.min_notice_days.days - 1.day
    end

    def started?
      return false if start_at.nil?

      Time.zone.today >= start_at
    end

    def refund_due?
      long_term_cancelled_at.present? && (last_payment.service_end_at - long_term_cancelled_at.end_of_day).positive?
    end

    def long_term_cancellable?
      return false if long_term_cancelled_at.present? && long_term_cancelled_at <= Time.zone.now
      return false unless long_lease_transformed_terminallable?

      long_term? && long_term_cancelled_at.nil?
    end

    def long_lease_transformed_terminallable?
      return true if long_term_start_at.blank?

      (long_term_start_at - notice_days) <= Time.zone.now
    end

    def long_lease_transformed_endable?
      return true if long_term_start_at.blank?

      long_term_cancelled_at >= long_term_start_at
    end

    def cancellation_notice_given?
      long_term_cancelled_at.present? && active?
    end

    def last_long_lease_payment?
      return false if long_term_cancelled_at.blank?

      days_to_cancel = long_term_cancelled_at.end_of_day - next_service_start_at
      days_to_cancel.positive? && days_to_cancel < INTERVAL.days
    end

    def long_term_ended?
      long_term? && (early_ended? || reviewed?)
    end

    def discounted?
      discount_code.present?
    end

    def discounted_endable?
      return true unless discounted?

      total_lease_days = (long_term_cancelled_at - start_at).to_i + 1
      case discount_code
      when 'one_month'
        return true if total_lease_days >= Order::DISCOUNT_REQUIRED_DAYS_ONE_MONTH
      when 'two_months'
        return true if total_lease_days >= Order::DISCOUNT_REQUIRED_DAYS_TWO_MONTHS
      when 'six_months'
        return true if total_lease_days >= Order::DISCOUNT_REQUIRED_DAYS_SIX_MONTHS
      else
        false
      end
    end

    def cancellable_by_admin?
      start_at.present? && start_at > Time.zone.today
    end

    def reviewable_by_admin?
      (completed? || early_ended?) && note.present?
    end

    def last_payment_completed?
      last_payment.present? && last_payment.completed?
    end

    def full_refundable_by_admin?
      may_full_refunded? && long_term_cancelled_at.nil?
    end

    def finished?
      completed? || early_ended? || reviewed?
    end
  end
end
