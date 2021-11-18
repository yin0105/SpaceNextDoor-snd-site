# frozen_string_literal: true

module Report
  class FinancialSummary < Report::Base
    def initialize(args = {})
      super
    end

    private

    def pdf_content
      data = find_payments
      data.map do |payment|
        refund = payouts_filter_by_type(payment.payouts, :refund)
        refund = refund.present? ? refund.sum(&:amount) : zero_money
        total = (payment.rent + payment.guest_service_fee + payment.host_service_fee) - refund
        {
          identity: payment.identity,
          guest_id: payment.guest.id,
          guest_name: payment.guest.name,
          all_rent: !is_snd_id?(payment.order.host_id) ? payment.rent : zero_money,
          snd_rent: is_snd_id?(payment.order.host_id) ? payment.rent : zero_money,
          guest_service_fee: payment.guest_service_fee,
          host_service_fee: payment.host_service_fee,
          refund: refund,
          total: total,
          service_start_at: I18n.l(payment.service_start_at, format: :mail_date),
          service_end_at: I18n.l(payment.service_end_at, format: :mail_date)
        }
      end
    end

    def csv_content
      data = find_payments
      data.map do |payment|
        refund = payouts_filter_by_type(payment.payouts, :refund)
        refund = refund.present? ? refund.sum(&:amount) : zero_money
        total = (payment.rent + payment.guest_service_fee + payment.host_service_fee) - refund
        [
          payment.guest.id,
          payment.guest.name,
          !is_snd_id?(payment.order.host_id) ? payment.rent.format : zero_money.format,
          is_snd_id?(payment.order.host_id) ? payment.rent.format : zero_money.format,
          payment.guest_service_fee.format,
          payment.host_service_fee.format,
          refund.format,
          total.format,
          I18n.l(payment.service_start_at, format: :mail_date),
          I18n.l(payment.service_end_at, format: :mail_date)
        ]
      end
    end

    def find_payments
      Payment.includes(:payouts, order: %i[guest space]).where(Payment.arel_table[:created_at].between(start_date..end_date))
    end

    def csv_header
      ['Guest ID', 'Guest', 'Guest Rent (All Others)', 'Guest Rent (SND)', 'Guest Service Fee', 'Host Service Fee', 'Refund', 'Total', 'Start At', 'End At']
    end
  end
end
