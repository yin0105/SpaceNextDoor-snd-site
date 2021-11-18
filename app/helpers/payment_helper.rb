# frozen_string_literal: true

module PaymentHelper
  def render_payment_actions(payment)
    return invoice_button(payment) if payment.success? || payment.resolved?
    return repay_button(payment) if payment.failed?
  end

  def invoice_button(payment)
    type = guest_tab? ? 'guest' : 'host'
    link_to 'Invoice', order_invoice_path(payment.order, payment, identity: type), class: 'button bg-gray-deep'
  end

  def repay_button(payment)
    return unless guest_tab?

    link_to 'Retry', order_payments_path(payment.order), class: 'button bg-gray-deep', data: { method: :post }
  end

  def display_charged_identity(payment)
    if guest_tab?
      "Charged to: #{payment.user.payment_method.identifier}"
    else
      "Booked by: #{payment.user.name}"
    end
  end

  def display_invoice_amount(payment)
    if guest_tab?
      payment.amount.format
    else
      payment.refund_due? ? payment.early_end_host_service_fee.format : payment.host_service_fee.format
    end
  end

  def display_rent_to_host_amount(payment)
    "Rent to Host: #{payment.host_rent.format}" unless guest_tab?
  end
end
