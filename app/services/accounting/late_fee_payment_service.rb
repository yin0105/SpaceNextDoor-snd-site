# frozen_string_literal: true

module Accounting
  class LateFeePaymentService
    def initialize(late_fee_payment)
      @late_fee_payment = late_fee_payment
      @guest = late_fee_payment.user.as_guest.account
      @temporary_credit1 = Accounting.account(:tc1)
      @temporary_credit2 = Accounting.account(:tc2)
      @revenue = Accounting.account(:revenue)
    end

    def lock_accounts
      [@guest, @temporary_credit1, @temporary_credit2, @revenue]
    end

    def start
      user_pay
      collect_service_fee
      charge
    end

    private

    def user_pay
      DoubleEntry.transfer(
        @late_fee_payment.amount,
        from: @guest,
        to: @temporary_credit1,
        code: Accounting::CODE[:pay]
      )
    end

    def collect_service_fee
      DoubleEntry.transfer(
        @late_fee_payment.guest_service_fee + @late_fee_payment.premium,
        from: @temporary_credit1,
        to: @revenue,
        code: Accounting::CODE[:receive_gsf]
      )
    end

    def charge
      DoubleEntry.transfer(
        @late_fee_payment.rent,
        from: @temporary_credit1,
        to: @temporary_credit2,
        code: Accounting::CODE[:charge]
      )
    end
  end
end
