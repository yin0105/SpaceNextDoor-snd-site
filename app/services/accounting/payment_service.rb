# frozen_string_literal: true

module Accounting
  class PaymentService
    def initialize(payment)
      @payment = payment
      @guest = payment.user.as_guest.account
      @temporary_credit1 = Accounting.account(:tc1)
      @temporary_credit2 = Accounting.account(:tc2)
      @revenue = Accounting.account(:revenue)
    end

    def lock_accounts
      [@guest, @temporary_credit1, @temporary_credit2, @revenue]
    end

    def start
      user_pay
      charge
      collect_service_fee
    end

    private

    def user_pay
      DoubleEntry.transfer(
        @payment.amount,
        from: @guest,
        to: @temporary_credit1,
        code: Accounting::CODE[:pay]
      )
    end

    def charge
      DoubleEntry.transfer(
        @payment.rent + @payment.deposit,
        from: @temporary_credit1,
        to: @temporary_credit2,
        code: Accounting::CODE[:charge]
      )
    end

    def collect_service_fee
      DoubleEntry.transfer(
        @payment.guest_service_fee + @payment.premium,
        from: @temporary_credit1,
        to: @revenue,
        code: Accounting::CODE[:receive_gsf]
      )
    end
  end
end
