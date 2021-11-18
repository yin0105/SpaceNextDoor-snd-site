# frozen_string_literal: true

module MailerHelper
  def customed_mail(record, action, opts = {}, &block)
    initialize_from_record(record)
    mail headers_for(action, opts), &block
  end

  def render_transaction_period_end(payout)
    return l payout.order.long_term_cancelled_at, format: :mail_date if payout.order.early_ended?

    l payout.payment_service_end_at, format: :mail_date
  end

  def render_payout_refund_period_start(payout)
    return l payout.order.long_term_cancelled_at + 1.day, format: :mail_date if payout.order.long_term?

    l @payout.payment_service_start_at, format: :mail_date
  end

  def render_payout_refund_item(payout)
    price = payout.order.price.format(symbol: false).to_s
    refund_days = payout.order.long_term? ? (Order::INTERVAL - payout.payment.days_rented).to_s : payout.order.days.to_s

    '$' + price + '/day * ' + refund_days + ' of days'
  end

  def payout_duration(payout)
    '(' + payout.duration.to_s + ' days)'
  end
end
