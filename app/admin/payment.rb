# frozen_string_literal: true

ActiveAdmin.register Payment, as: 'Transaction' do
  menu priority: 4

  actions :index

  includes order: %i[guest host space service_fee]

  filter :user
  filter :search_identity, label: 'Transaction No', as: :string, filters: [:eq]
  filter :service_start_at
  filter :service_end_at
  filter :created_at
  filter :rent_cents
  filter :deposit_cents
  filter :guest_service_fee_cents
  filter :host_service_fee_cents
  filter :deposit_cents

  scope :all, default: true
  scope :pending
  scope :success
  scope :retry
  scope :failed
  scope :resolved

  controller do
    def scoped_collection
      if params[:format] == 'csv'
        end_of_association_chain.includes(order: [:service_fee, space: :address])
      else
        super
      end
    end

    def csv_filename
      "Transactions-#{Time.zone.today}.csv"
    end
  end

  index download_links: [:csv] do
    id_column

    column :guest
    column :host
    column 'Booking Period', :order_days
    column 'Transaction No.', :identity
    column 'Transaction Period', :period
    column 'Start At' do |payment|
      payment&.service_start_at
    end
    column 'End At' do |payment|
      payment&.service_end_at
    end
    column(:amount) { |payment| payment.amount.format }
    column(:rent_to_host) { |payment| payment.host_rent.format }
    column 'Guest Insurance' do |payment|
      payment.premium.format
    end
    column(:guest_service_fee, sortable: :guest_service_fee_cents) do |payment|
      payment.refund_due? ? payment.early_end_guest_service_fee.format : payment.guest_service_fee.format
    end
    column(:host_service_fee, sortable: :host_service_fee_cents) do |payment|
      payment.refund_due? ? payment.early_end_host_service_fee.format : payment.host_service_fee.format
    end
    column(:deposit, sortable: :deposit_cents) { |payment| payment.deposit.format }
    column 'Refund Amount' do |payment|
      (payment.payouts.refund.last.amount - payment.order.add_fee).format if payment.refund_due? && payment.payouts.refund.present?
    end
    column :created_at do |payment|
      payment&.created_at
    end
    column(:status) { |payment| status_tag payment.status }
  end

  csv do
    column :id
    column :guest do |payment|
      payment.guest.dashboard_display_name
    end
    column :host do |payment|
      payment.host.dashboard_display_name
    end
    column('Space Id') do |payment|
      payment.space.id
    end
    column 'Space Address in Full' do |payment|
      payment.space.address
    end
    column 'Postal Code' do |payment|
      payment.space.address.postal_code
    end
    column 'Area' do |payment|
      payment.space.address.area
    end
    column :storage do |payment|
      payment.space.name
    end
    column :unit_size do |payment|
      payment.space.area
    end
    column :booking_period, &:order_days
    column :transaction_no, &:identity
    column :transaction_period, &:period
    column 'Start At' do |payment|
      I18n.l(payment.service_start_at, format: :active_admin_date)
    end
    column 'End At' do |payment|
      I18n.l(payment.service_end_at, format: :active_admin_date)
    end
    column(:amount) { |payment| payment.amount.format }
    column(:rent_to_host) { |payment| payment.host_rent.format }
    column(:guest_insurance) { |payment| payment.premium.format }
    column(:guest_service_fee, sortable: :guest_service_fee_cents) do |payment|
      payment.refund_due? ? payment.early_end_guest_service_fee.format : payment.guest_service_fee.format
    end
    column(:host_service_fee, sortable: :host_service_fee_cents) do |payment|
      payment.refund_due? ? payment.early_end_host_service_fee.format : payment.host_service_fee.format
    end
    column(:deposit, sortable: :deposit_cents) { |payment| payment.deposit.format }
    column 'Refund Amount' do |payment|
      (payment.payouts.refund.last.amount - payment.order.add_fee).format if payment.refund_due? && payment.payouts.refund.present?
    end
    column :created_at do |payment|
      I18n.l(payment.created_at, format: :active_admin_date)
    end
    column :status, &:status
  end
end
