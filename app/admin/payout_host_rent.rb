# frozen_string_literal: true

ActiveAdmin.register Payout, as: 'Host Rent' do
  menu priority: 3, parent: 'Payout'

  include AdminPayout

  actions :index

  controller do
    include AdminLog

    def scoped_collection
      end_of_association_chain.rent
    end

    def csv_filename
      "Host_Rent-#{Time.zone.today}.csv"
    end
  end

  includes payment: { order: %i[host space service_fee] }

  filter :created_at

  index download_links: [:csv] do
    id_column
    column :host
    column :guest
    column :order
    column 'Order Period' do |payout|
      "#{payout.order_days} day(s)"
    end
    column 'Transaction ID' do |payout|
      payout.payment_identity.to_s
    end
    column 'Transaction Period' do |payout|
      transaction_period(payout)
    end
    column 'Payout Period' do |payout|
      payout_host_period(payout)
    end
    column 'Rent', &:period_rent
    column 'Host Service Fee', &:period_host_service_fee
    column 'Payable To Host', &:amount
    column 'Date Payable To Host' do |payout|
      date_payable_to_host(payout)
    end
    column 'Actual Paid Date' do |payout|
      payout&.actual_paid_at
    end
    column 'Service starts at' do |payout|
      payout&.payment&.service_start_at
    end
    column 'Status' do |payout|
      status_tag payout.pending? ? nil : :yes, label: payout.status
    end
    column do |payout|
      if payout.pending?
        link_to 'Mark Paid', '#', class: 'mark-paid-admin', data: { request_path: pay_admin_host_rent_path(payout) }
      end
    end
  end

  csv do
    column :id
    column(:host) { |payout| payout.host.dashboard_display_name }
    column(:guest) { |payout| payout.guest.dashboard_display_name }
    column 'Order ID' do |payout|
      payout.order.id
    end
    column 'Order Period' do |payout|
      "#{payout.order_days} day(s)"
    end
    column 'Transaction ID' do |payout|
      payout.payment_identity.to_s
    end
    column 'Transaction Period' do |payout|
      transaction_period(payout)
    end
    column 'Payout Period' do |payout|
      payout_host_period(payout)
    end
    column 'Rent', &:period_rent
    column 'Host Service Fee', &:period_host_service_fee
    column 'Payable To Host', &:amount
    column 'Date Payable To Host' do |payout|
      I18n.l(date_payable_to_host(payout), format: :active_admin_date)
    end
    column 'Actual Paid Date' do |payout|
      payout.actual_paid_at ? I18n.l(payout.actual_paid_at, format: :abbr_with_dash) : nil
    end
    column :status, &:status
  end
end
