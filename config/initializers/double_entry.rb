# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  DoubleEntry.configure do |config|
    config.accounts = nil
    config.transfers = nil

    config.define_accounts do |accounts|
      user_scope = accounts.active_record_scope_identifier(User)
      accounts.define(identifier: :guest, scope_identifier: user_scope)
      accounts.define(identifier: :guest_payout, scope_identifier: user_scope)
      accounts.define(identifier: :host, scope_identifier: user_scope, positive_only: true)
      accounts.define(identifier: :host_payout, scope_identifier: user_scope)

      accounts.define(identifier: :temporary_credit_1)
      accounts.define(identifier: :temporary_credit_2)

      accounts.define(identifier: :rent)
      accounts.define(identifier: :deposit)
      accounts.define(identifier: :receipt_under_custody)

      accounts.define(identifier: :revenue, positive_only: true)
    end

    config.define_transfers do |transfers|
      # Payment
      transfers.define(from: :guest, to: :temporary_credit_1, code: :pay)

      transfers.define(from: :temporary_credit_1, to: :revenue, code: :receive_guest_service_fee)
      transfers.define(from: :temporary_credit_1, to: :temporary_credit_2, code: :charge)

      # Service Start
      transfers.define(from: :temporary_credit_2, to: :rent, code: :collect_rent)
      transfers.define(from: :temporary_credit_2, to: :deposit, code: :collect_deposit)
      transfers.define(from: :temporary_credit_2, to: :receipt_under_custody, code: :collect_host_service_fee)

      # Service End
      transfers.define(from: :rent, to: :host_payout, code: :hold_rent)
      transfers.define(from: :receipt_under_custody, to: :revenue, code: :receive_host_service_fee)

      # Order (Review/Completed/Cancel)
      transfers.define(from: :deposit, to: :host_payout, code: :hold_damage)
      transfers.define(from: :deposit, to: :guest_payout, code: :hold_deposit)
      transfers.define(from: :temporary_credit_2, to: :guest_payout, code: :hold_refund)

      # Confirm (Damage/Rent/Deposit/Refund)
      transfers.define(from: :host_payout, to: :host, code: :payout_rent)
      transfers.define(from: :host_payout, to: :host, code: :payout_damage)
      transfers.define(from: :guest_payout, to: :guest, code: :payout_deposit)
      transfers.define(from: :guest_payout, to: :guest, code: :payout_refund)
    end
  end
end
