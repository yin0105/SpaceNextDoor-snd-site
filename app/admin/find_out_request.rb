# frozen_string_literal: true

ActiveAdmin.register FindOutRequest, as: 'Find Out More' do
  menu label: 'Find Out More'

  actions :index, :show

  includes %i[space user]

  controller do
    def csv_filename
      "Find_Out_More-#{Time.zone.today}.csv"
    end
  end

  filter :identity, as: :select, collection: proc { FindOutRequest.identities }
  filter :name
  filter :phone
  filter :email
  filter :space
  filter :user
  filter :size
  filter :start_at
  filter :end_at

  index title: 'Find Out More', download_links: [:csv] do
    id_column
    column(:created_at) { |resource| resource&.created_at }
    column :name
    column :phone
    column :email
    column :space
    column(:start_at) { |resource| resource&.start_at }
    column :location
    column(:size) { |resource| resource.size.to_s + ' sqm' }
    column :address
    column :postal_code
    column :description
    column :identity
    column :user
    column(:details) { |resource| link_to 'Details', admin_find_out_more_path(resource) }
  end

  csv do
    column :id
    column(:created_at) { |resource| I18n.l(resource.created_at, format: :active_admin_date) }
    column :name
    column :phone
    column :email
    column(:space) { |resource| resource&.dashboard_display_name }
    column(:start_at) { |resource| I18n.l(resource.start_at, format: :active_admin_date) }
    column :location
    column(:size) { |resource| resource.size.to_s }
    column :address
    column :postal_code
    column :description
    column :identity
    column(:user) { |resource| resource.user&.dashboard_display_name }
  end

  show do
    attributes_table do
      row :name
      row :phone
      row :email
      row :location
      row :address
      row :postal_code
      row :start_at
      row :end_at
      row :description
      row 'Size (sqm)' do
        find_out_more.size
      end
      row :accept_receive_updates
      row :space
      row :user
      row :created_at
      row :updated_at
    end
  end
end
