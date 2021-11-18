# frozen_string_literal: true

class ConfirmService
  class WrongTypeError < RuntimeError; end
  class PayOutTimeBlankError < RuntimeError; end

  def initialize(payout, actual_paid_at)
    @payout = payout
    @actual_paid_at = Time.zone.parse(actual_paid_at)
  end

  def pay!
    raise PayOutTimeBlankError if @actual_paid_at.blank?

    action = "accounting/#{@payout.type}_confirm_service".camelize.constantize
    DoubleEntry.lock_accounts(*action.new(@payout).lock_accounts) do
      @payout.update(actual_paid_at: @actual_paid_at)
      @payout.pay!
    end
  end
end
