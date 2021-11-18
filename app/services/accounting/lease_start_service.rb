# frozen_string_literal: true

module Accounting
  class LeaseStartService
    def initialize(payment)
      @payment = payment
      @temporary_credit2 = Accounting.account(:tc2)
      @rent = Accounting.account(:rent)
      @deposit = Accounting.account(:deposit)
      @ruc = Accounting.account(:ruc)
    end

    def start
      DoubleEntry.lock_accounts(@temporary_credit2, @rent, @deposit, @ruc) do
        collect_rent
        collect_deposit
        collect_service_fee
      end
    end

    private

    def collect_rent
      DoubleEntry.transfer(
        @payment.host_rent,
        from: @temporary_credit2,
        to: @rent,
        code: Accounting::CODE[:collect_rent]
      )
    end

    def collect_deposit
      DoubleEntry.transfer(
        @payment.deposit,
        from: @temporary_credit2,
        to: @deposit,
        code: Accounting::CODE[:collect_deposit]
      )
    end

    def collect_service_fee
      DoubleEntry.transfer(
        @payment.host_service_fee,
        from: @temporary_credit2,
        to: @ruc,
        code: Accounting::CODE[:collect_hsf]
      )
    end
  end
end
