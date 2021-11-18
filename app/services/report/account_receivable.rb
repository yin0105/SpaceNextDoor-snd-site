# frozen_string_literal: true

module Report
  class AccountReceivable < Report::Base
    def initialize(args = {})
      super
    end

    private

    def pdf_content
      data = find_payments
      data.map do |payment|
        {
          space_id: payment.space.id,
          identity: payment.identity,
          guest_name: payment.guest.name,
          beginning_balance: beginning_balance(payment),
          rent: payment.rent,
          guest_service_fee: payment.guest_service_fee,
          deposit: payment.deposit,
          amount: payment.amount,
          ending_balance: ending_balance(payment)
        }
      end
    end

    def csv_content
      data = find_payments
      data.map do |payment|
        [
          payment.space.id,
          payment.identity,
          payment.guest.name,
          payment.space.address,
          payment.space.address.postal_code,
          beginning_balance(payment).format,
          payment.rent.format,
          payment.guest_service_fee.format,
          payment.deposit.format,
          "-#{payment.amount.format}",
          ending_balance(payment).format,
          I18n.l(payment.service_start_at, format: :mail_date),
          I18n.l(payment.service_end_at, format: :mail_date),
          I18n.l(payment.created_at, format: :mail_date),
          move_out_date(payment),
          payment.order.monthly_amount.format
        ]
      end
    end

    def find_payments
      payments = if @export_type == 'csv'
                   Payment.includes(order: [:guest, space: :address])
                 else
                   Payment.includes(order: %i[guest space])
                 end
      payments.where(Payment.arel_table[:created_at].between(start_date..end_date))
    end

    def csv_header
      ['Space ID', 'Transaction No.', 'Guest', 'Address', 'Postal code', 'Beginning Balance', 'Guest Rent', 'Guest Service Fee', 'Deposit', 'Payment', 'Ending Balance', 'Start At', 'End At', 'Created At', 'Move out Date', 'Daily Rate x 30 days']
    end

    def beginning_balance(payment)
      payment.success? ? zero_money : payment.amount
    end

    def ending_balance(payment)
      return zero_money if payment.success? || (payment.resolved? && payment.created_at&.month == payment.resolved_at&.month)

      payment.amount
    end
  end
end
