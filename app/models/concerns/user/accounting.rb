# frozen_string_literal: true

class User
  module Accounting
    extend ActiveSupport::Concern

    def account
      DoubleEntry.account(double_entry_account_id, scope: becomes(User))
    end

    def pending_account
      DoubleEntry.account(double_entry_account_id(true), scope: becomes(User))
    end

    private

    def double_entry_account_id(payout = false)
      account_name = self.class.name.demodulize.downcase
      account_name = "#{account_name}_payout" if payout
      ::Accounting::ACCOUNT[account_name.to_sym]
    end
  end
end
