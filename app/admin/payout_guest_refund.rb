# frozen_string_literal: true

ActiveAdmin.register Payment, as: 'Guest Cancellation And Deposit Refund' do
  menu priority: 5, parent: 'Payout', label: 'Guest Termination / Cancellation and Deposit Refunds'

  actions :index

  member_action :pay, method: :patch do
    payouts = resource.payouts.where(type: %i[deposit refund], status: :pending)
    payouts.each do |payout|
      ConfirmService.new(payout, params[:actual_paid_at]).pay!
      create_action_log(target: payout, status: :succeed)
    end

    flash[:notice] = 'Marked as paid'
    head :ok
  end

  controller do
    helper ActiveAdmin::ViewsHelper
    include AdminLog

    def scoped_collection
      end_of_association_chain.joins(:payouts).where(payouts: { type: %i[deposit refund] }).distinct
    end

    def csv_filename
      "Guest_Termination_or_Cancellation_or_Deposit_Refunds-#{Time.zone.today}.csv"
    end
  end

  includes order: %i[down_payment last_payment space service_fee guest]

  filter :order_id

  index download_links: [:csv], title: 'Guest Termination / Cancellation and Deposit Refunds' do
    id_column
    column :guest
    column :order
    column 'Deposit' do |payment|
      payment.order.deposit
    end
    column 'Damage Amount' do |payment|
      payment.payouts.damage.last&.amount
    end
    column 'Refund Amount(Deposit)' do |payment|
      payment.payouts.deposit.last&.amount
    end
    column 'Cancelled By' do |payment|
      if payment.order.long_term_cancelled_at.present? && payment.order.long_term_cancelled_at >= payment.order.last_payment.service_start_at
        'Guest'
      else
        'Admin'
      end
    end
    column 'Down Payment ID' do |payment|
      payment.order.down_payment.identity
    end
    column 'Transaction ID', :identity
    column 'Transaction Period' do |payment|
      "#{payment.days}  day(s)"
    end
    column 'Transaction Amount', :amount
    column 'Guest S.C.' do |payment|
      if payment.order.full_refunded?
        payment.full_refund_guest_service_fee
      elsif payment.order.cancelled?
        payment.guest_service_fee
      else
        payment.early_end_guest_service_fee
      end
    end
    column 'Add Fee' do |payment|
      payment.order.add_fee
    end
    column 'Refund Amount' do |payment|
      (payment.payouts.refund.last&.amount || 0) - payment.order.add_fee
    end
    column 'Refund Due Date(i.e. SND to pay guest due date)' do |payment|
      if payment.order.long_term_cancelled_at.present?
        payment.order.long_term_cancelled_at + 2.weeks
      else
        payment.order.end_at + 2.weeks
      end
    end
    column 'Actual Paid Date' do |payment|
      payment.payouts.where(type: %i[deposit refund]).last&.actual_paid_at
    end
    column 'Refund Status' do |payment|
      if deposit_and_refund_both_paid?(payment)
        status_tag :yes, label: 'PAID'
      else
        status_tag nil, label: 'PENDING'
      end
    end
    column do |payment|
      if (payment.order.reviewed? || payment.order.full_refunded? || payment.order.cancelled?) && !deposit_and_refund_both_paid?(payment)
        link_to 'Mark Paid', '#', class: 'mark-paid-admin', data: { request_path: pay_admin_guest_cancellation_and_deposit_refund_path(payment) }
      end
    end
  end

  csv do
    column :id
    column(:guest) { |payment| payment.guest.dashboard_display_name }
    column 'Order ID' do |payment|
      payment.order.id
    end
    column 'Deposit' do |payment|
      payment.order.deposit
    end
    column 'Damage Amount' do |payment|
      payment.payouts.damage.last&.amount
    end
    column 'Refund Amount(Deposit)' do |payment|
      payment.payouts.deposit.last&.amount
    end
    column 'Cancelled By' do |payment|
      if payment.order.long_term_cancelled_at.present? && payment.order.long_term_cancelled_at >= payment.order.last_payment.service_start_at
        'Guest'
      else
        'Admin'
      end
    end
    column 'Down Payment ID' do |payment|
      payment.order.down_payment.identity
    end
    column 'Transaction ID', &:identity
    column 'Transaction Period' do |payment|
      "#{payment.days}  day(s)"
    end
    column 'Transaction Amount', &:amount
    column 'Guest S.C.' do |payment|
      if payment.order.full_refunded?
        payment.full_refund_guest_service_fee
      elsif payment.order.cancelled?
        payment.guest_service_fee
      else
        payment.early_end_guest_service_fee
      end
    end
    column 'Add Fee' do |payment|
      payment.order.add_fee
    end
    column 'Refund Amount' do |payment|
      (payment.payouts.refund.last&.amount || 0) - payment.order.add_fee
    end
    column 'Refund Due Date(i.e. SND to pay guest due date)' do |payment|
      if payment.order.long_term_cancelled_at.present?
        payment.order.long_term_cancelled_at + 2.weeks
      else
        payment.order.end_at + 2.weeks
      end
    end
    column 'Actual Paid Date' do |payment|
      date = payment.payouts.where(type: %i[deposit refund]).last&.actual_paid_at
      date.present? ? I18n.l(date, format: :abbr_with_dash) : nil
    end
    column 'Refund Status' do |payment|
      deposit_and_refund_both_paid?(payment) ? 'PAID' : 'PENDING'
    end
  end
end
