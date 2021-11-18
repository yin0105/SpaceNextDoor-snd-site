# frozen_string_literal: true

ActiveAdmin.register Space do
  menu priority: 2

  includes %i[user last_valid_order]

  actions :index, :show
  permit_params :name, :description, :status, :reasons_for_disapproval

  member_action :front_end do
    session[:_admin_mode] = true
    sign_in(:user, resource.user, bypass: true)
    redirect_to resource
  end

  member_action :approve, method: :post do
    resource.approve!
    create_action_log(status: :succeed)
    redirect_to admin_spaces_path
  end

  member_action :activate, method: :post do
    resource.show!
    create_action_log(status: :succeed)
    redirect_to admin_spaces_path
  end

  member_action :deactivate, method: :post do
    resource.hide!
    create_action_log(status: :succeed)
    redirect_to admin_spaces_path
  end

  member_action :soft_delete, method: :post do
    resource.soft_delete!
    create_action_log(status: :succeed)
    redirect_to admin_spaces_path
  end

  member_action :edit_disapproval do
    resource
    render :disapprove
  end

  member_action :update_disapproval, method: :patch do
    resource

    if permitted_params[:space][:reasons_for_disapproval].blank?
      resource.errors[:reasons_for_disapproval] << "can't be blank"
      create_action_log(status: :failed)
      return render :disapprove
    end

    resource.update(reasons_for_disapproval: permitted_params[:space][:reasons_for_disapproval])
    resource.disapprove!
    create_action_log(status: :succeed)
    redirect_to admin_spaces_path
  end

  member_action :toggle_insurance_enable, method: :post do
    ToggleSpaceInsuranceService.new(resource).start!
    create_action_log(status: :succeed)
    redirect_to request.referer + "#space_#{resource.id}"
  end

  controller do
    helper ActiveAdmin::ViewsHelper
    include AdminLog

    def scoped_collection
      if params[:format] == 'csv'
        end_of_association_chain.includes(:address).where.not(status: :soft_deleted)
      else
        end_of_association_chain.where.not(status: :soft_deleted)
      end
    end

    def csv_filename
      "Spaces-#{Time.zone.today}.csv"
    end
  end

  scope :all, default: true
  scope :pending
  scope :disapproved

  filter :id
  filter :property, as: :select, label: 'Type of Property', collection: Space::PROPERTY
  filter :created_at

  index download_links: [:csv] do
    selectable_column
    id_column
    column :name
    column 'Type of Property', &:property
    column :status
    column :size do |space|
      space.area.to_s.concat(' sqm')
    end
    column :price do |space|
      space.daily_price.format(with_currency: true)
    end
    column :offering_promotion do |space|
      space.discount_code? ? I18n.t('.backstage.space.' + space.discount_code) : I18n.t('.backstage.space.none')
    end
    column('Insurance') do |space|
      if space.activated?
        link_to display_insurance_enable(space), toggle_insurance_enable_admin_space_path(space), method: :post, data: { confirm: "This insurance will be #{!space.insurance_enable? ? 'enabled' : 'disabled'}. Are you sure?" }
      else
        display_insurance_enable(space)
      end
    end
    column :active_booking do |space|
      if space.activated_order.present?
        link_to space.activated_order.guest.name, admin_user_path(space.activated_order.guest)
      else
        I18n.t('.backstage.space.none')
      end
    end
    column 'Active Booking No.' do |space|
      if space.activated_order.present?
        link_to space.activated_order.id, admin_booking_path(space.activated_order.id)
      else
        I18n.t('.backstage.space.none')
      end
    end
    column('Last Order Date', &:last_valid_order_date)
    column :vacant_days do |space|
      space.vacant_days.positive? ? space.vacant_days : 0
    end
    column :host_name do |space|
      link_to space.user.name.to_s, admin_user_path(space.user)
    end
    column :created_at do |space|
      space&.created_at
    end
    actions defaults: false do |space|
      item 'View', admin_space_path(space)
      item 'Go to Page', front_end_admin_space_path(space)
      item 'Approve', approve_admin_space_path(space), method: :post if space.may_approve?
      item 'Disapprove', edit_disapproval_admin_space_path(space) if space.may_disapprove?
      item 'Activate', activate_admin_space_path(space), method: :post, data: { confirm: 'Are you sure?' } if  space.may_show?
      item 'Deactivate', deactivate_admin_space_path(space), method: :post, data: { confirm: 'Are you sure?' } if space.may_hide?
      item 'Delete', soft_delete_admin_space_path(space), method: :post, data: { confirm: 'The space will be deleted. Are you sure?' } if space.may_soft_delete?
    end
  end

  show do
    attributes_table do
      row :name
      row :description
      row :user
      row :status
      row :govid_required
      row :created_at
      row :updated_at
      row :spaceable_type
      row :spaceable
      row :daily_price_cents
      row :daily_price_currency
      row :minimum_rent_days
      row :area
      row :height
      row :property
      row :discount_code
      row :auto_extend_slot
      row :insurance_enable
      row :reasons_for_disapproval
      row :rent_payout_type do |space|
        I18n.t("active_admin.space.rent_payout_type.#{space.rent_payout_type}")
      end
      row :featured
    end
  end

  csv do
    column :id
    column :name
    column 'Type of Property', &:property
    column 'Postal Code' do |space|
      space.address.postal_code
    end
    column 'Address', &:address
    column :status
    column :active_booking do |space|
      space.activated_order&.guest&.name || I18n.t('.backstage.space.none')
    end
    column 'Active Booking No.' do |space|
      space.activated_order&.id || I18n.t('.backstage.space.none')
    end
    column :size, &:area
    column :price, &:daily_price
    column('Insurance', &:insurance?)
    column :offering_promotion do |space|
      space.discount_code? ? I18n.t('.backstage.space.' + space.discount_code) : I18n.t('.backstage.space.none')
    end
    column('Last Order Date') do |space|
      I18n.l(space.last_valid_order_date, format: :active_admin_date)
    end
    column :vacant_days do |space|
      space.vacant_days.positive? ? space.vacant_days : 0
    end
    column :host_name do |space|
      space.user.name
    end
    column :created_at do |space|
      I18n.l(space.created_at, format: :active_admin_date)
    end
  end

  form do |_|
    inputs 'Information' do
      input :name
      input :description
    end
    actions
  end
end
