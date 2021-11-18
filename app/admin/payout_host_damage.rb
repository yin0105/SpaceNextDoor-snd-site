# frozen_string_literal: true

ActiveAdmin.register Payout, as: 'Host Damage' do
  menu priority: 4, parent: 'Payout'

  include AdminPayout

  actions :index

  controller do
    include AdminLog

    def scoped_collection
      end_of_association_chain.damage
    end

    def csv_filename
      "Host_Damages-#{Time.zone.today}.csv"
    end
  end

  includes payment: :order

  index download_links: [:csv] do
    id_column
    column :host
    column :guest
    column :order
    column 'Transaction ID', :payment_identity
    column :amount
    column 'Status' do |payout|
      status_tag payout.pending? ? nil : :yes, label: payout.status
    end
    column 'Actual Paid Date' do |payout|
      payout&.actual_paid_at
    end
    column do |payout|
      if payout.pending?
        link_to 'Mark Paid', '#', class: 'mark-paid-admin', data: { request_path: pay_admin_host_damage_path(payout) }
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
    column 'Transaction ID', &:payment_identity
    column :amount, &:amount
    column 'Actual Paid Date' do |payout|
      payout.actual_paid_at ? I18n.l(payout.actual_paid_at, format: :abbr_with_dash) : nil
    end
    column :status, &:status
  end
end
