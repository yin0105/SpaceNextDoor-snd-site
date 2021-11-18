# frozen_string_literal: true

module Report
  class SecurityDepositLiability < Report::Base
    def initialize(args = {})
      super
    end

    private

    def pdf_content
      data = find_payments
      data.map do |payment|
        beginning_balance = payment.deposit > zero_money ? zero_money : payment.order.deposit
        applied_deposit = payouts_filter_by_type(payment.payouts, :damage)
        applied_deposit = applied_deposit.present? ? applied_deposit.sum(&:amount) : zero_money
        deposit_refund = payouts_filter_by_type(payment.payouts, :deposit)
        deposit_refund = deposit_refund.present? ? deposit_refund.sum(&:amount) : zero_money
        end_balance = beginning_balance - applied_deposit - deposit_refund
        move_out = move_out_date(payment)
        {
          space_id: payment.space.id,
          identity: payment.identity,
          guest_name: payment.guest.name,
          beginning_balance: beginning_balance,
          deposit: payment.deposit,
          applied_deposit: applied_deposit,
          deposit_refund: deposit_refund,
          ending_balance: end_balance,
          move_in: I18n.l(payment.order.start_at, format: :mail_date),
          move_out: move_out
        }
      end
    end

    def csv_content
      data = find_payments
      data.map do |payment|
        beginning_balance = payment.deposit > zero_money ? zero_money : payment.order.deposit
        applied_deposit = payouts_filter_by_type(payment.payouts, :damage)
        applied_deposit = applied_deposit.present? ? applied_deposit.sum(&:amount) : zero_money
        deposit_refund = payouts_filter_by_type(payment.payouts, :deposit)
        deposit_refund = deposit_refund.present? ? deposit_refund.sum(&:amount) : zero_money
        end_balance = beginning_balance - applied_deposit - deposit_refund
        move_out = move_out_date(payment)
        [
          payment.space.id,
          payment.identity,
          payment.guest.name,
          beginning_balance,
          payment.deposit.format,
          applied_deposit.format,
          deposit_refund.format,
          end_balance.format,
          I18n.l(payment.order.start_at, format: :mail_date),
          move_out
        ]
      end
    end

    def find_payments
      Payment.includes(:payouts, order: %i[guest space]).where(Payment.arel_table[:created_at].between(start_date..end_date))
    end

    def csv_header
      ['Space ID', 'Transaction No.', 'Guest', 'Beginning Balance', 'Deposit Payment', 'Applied Deposit', 'Deposit Refund', 'Ending Balance', 'Move in Date', 'Move out Date']
    end
  end
end
