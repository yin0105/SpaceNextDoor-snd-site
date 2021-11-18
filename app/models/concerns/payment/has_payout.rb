# frozen_string_literal: true

class Payment
  module HasPayout
    extend ActiveSupport::Concern
    def schedule_rent_payout
      payout_schedule_date = payout_date.end_of_day - 1.day

      schedule(:rent_payout, at: payout_schedule_date)
    end

    def payout_rent
      host_rent_rate = 1 - order.service_fee_host_rate
      payout_days = remain_rent_payout? ? (payout_end_at.to_date - payout_start_at.to_date).to_i + 1 : 0
      payout_days * price * host_rent_rate
    end

    def payout_host_service_fee
      payout_days = remain_rent_payout? ? (payout_end_at.to_date - payout_start_at.to_date).to_i + 1 : 0
      payout_days * price * order.service_fee_host_rate
    end

    def payout_start_at
      return service_start_at if order.one_month_rent_payout_type?

      last_rent_payout_end_at.beginning_of_day + 1.day
    end

    def payout_end_at
      return present_available_end_date.end_of_day if order.one_month_rent_payout_type?

      [last_rent_payout_end_at + Settings.order.ten_days_payout_cycle.day, present_available_end_date].min.end_of_day
    end

    def remain_rent_payout?
      return true if last_rent_payout.blank?

      last_rent_payout.end_at.to_date < present_available_end_date
    end

    def last_rent_payout
      payouts.rent.order(id: :ASC).last
    end

    def last_rent_payout_end_at
      return service_start_at.to_date - 1.day unless payouts.rent.exists?

      last_rent_payout.end_at.to_date
    end

    def present_available_end_date
      # return service_end_at at usual case
      # if order has long_term_cancelled_at return the min day
      if order.long_term_cancelled_at.present?
        return [order.long_term_cancelled_at.to_date, service_end_at.to_date].min
      end

      service_end_at.to_date
    end

    def payout_date
      # there are two types of payout rent to host
      # 1. Payout once a month: one month rent payout will be generated on 15th day since service start date at every period
      # 2. Payout every ten days: ten days rent payout will be generated every ten days
      return [service_start_at + Settings.order.one_month_payout_cycle.day - 1.day, present_available_end_date].min if order.one_month_rent_payout_type?

      payout_end_at
    end
  end
end
