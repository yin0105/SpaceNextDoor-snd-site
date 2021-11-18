# frozen_string_literal: true

ActiveAdmin.register InsuranceReport do
  menu label: 'Insurance'
  actions :index

  includes order: %i[guest space]
  includes order: { space: :address }

  controller do
    def csv_filename
      "InsuranceReport-#{Time.zone.today}.csv"
    end
  end

  filter :created_at, label: 'Create At'
  filter :service_start_at, label: 'Start At'
  filter :service_end_at, label: 'End At'
  filter :search_by_city, as: :select, collection: proc { Address.cities }, label: 'City'
  filter :search_by_area, as: :select, collection: proc { Address.areas }, label: 'Area'
  filter :search_by_address, as: :string, label: 'Street Address'

  index download_links: [:csv], title: 'Insurance' do
    column 'Space ID' do |payment|
      payment.space.id
    end
    column 'Guest Name' do |payment|
      payment.guest.name
    end
    column 'Space Address in Full' do |payment|
      payment.space.address
    end
    column 'Insurance Coverage' do |payment|
      Insurance.insurance_coverage(payment.insurance_type)
    end
    column 'Insurance Cost' do |payment|
      Insurance.insurance_cost(payment.insurance_type)
    end
    column 'Insurance Premium' do |payment|
      payment.premium.format
    end
    column 'Transaction ID', :identity
    column 'Start At' do |payment|
      payment&.service_start_at
    end
    column 'End At' do |payment|
      payment&.service_end_at
    end
    column 'Cancelled Date' do |payment|
      render_end_date(payment.order, :active_admin_date)
    end
    column 'Create At' do |payment|
      payment&.created_at
    end
  end

  csv do
    column 'Space Id' do |payment|
      payment.space.id
    end
    column 'Guest Name' do |payment|
      payment.guest.name
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
    column 'Insurance Coverage' do |payment|
      Insurance.insurance_coverage(payment.insurance_type)
    end
    column 'Insurance Cost' do |payment|
      Insurance.insurance_cost(payment.insurance_type)
    end
    column 'Insurance Premium' do |payment|
      payment.premium.format
    end
    column 'Transaction ID', &:identity
    column 'Start At' do |payment|
      I18n.l(payment&.service_start_at, format: :abbr_with_dash)
    end
    column 'End At' do |payment|
      I18n.l(payment&.service_end_at, format: :abbr_with_dash)
    end
    column 'Cancelled Date' do |payment|
      render_end_date(payment.order, :abbr_with_dash)
    end
    column 'Create At' do |payment|
      I18n.l(payment&.created_at, format: :abbr_with_dash)
    end
  end
end
