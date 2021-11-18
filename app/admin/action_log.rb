# frozen_string_literal: true

ActiveAdmin.register Admin::ActionLog, as: 'Log' do
  menu priority: 14

  actions :index, :show

  controller do
    helper ActiveAdmin::ViewsHelper

    def scoped_collection
      chain = end_of_association_chain.includes(:admin, :target)

      case current_scope&.name
      when 'Space'
        chain.includes(target: [:user])
      when 'Order'
        chain.includes(target: %i[space guest host])
      when 'Payout'
        chain.includes(target: [{ payment: { order: :space } }, :user])
      else
        chain
      end
    end
  end

  scope :summary, :all, default: true
  scope :order, :target_order
  scope :space, :target_space
  scope :payout, :target_payout
  scope :admin, :target_admin
  scope :user, :target_user
  scope :notification, :target_notification

  index do
    selectable_column
    id_column
    column(:operator) { |resource| resource&.admin }
    column(:target) do |resource|
      auto_link(resource.target, "#{resource[:target_type].split('::').first}##{resource[:target_id]}")
    end
    case current_scope&.name
    when 'Space'
      column(:space) { |resource| resource&.target }
      column(:host) { |resource| resource&.target&.user }
    when 'Order'
      column(:order) { |resource| resource&.target }
      column(:space) { |resource| resource&.target&.space }
      column(:host) { |resource| resource&.target&.host }
      column(:guest) { |resource| resource&.target&.guest }
    when 'Payout'
      column(:payout) { |resource| resource&.target }
      column(:transaction) { |resource| resource&.target&.payment&.identity }
      column(:booking) { |resource| resource&.target&.payment&.order }
      column(:space) { |resource| resource&.target&.payment&.order&.space }
      column(:guest) { |resource| resource&.target&.user }
    when 'User'
      column(:user) { |resource| resource&.target }
    when 'Admin'
      column(:admin) { |resource| resource&.target }
    when 'Notification'
      column(:notification) { |resource| resource&.target }
    end
    column :event
    column :status do |resource|
      status_tag resource.status, class: resource.succeed? ? 'yes' : ''
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :admin
      row(:target) { "#{resource[:target_type]}##{resource[:target_id]}" }
      row :event
      row :created_at
      row(:changes) do
        display_versions_change(
          PaperTrail::Version.where(request_id: resource[:request_id])
        )
      end
    end
  end

  filter :admin
  filter :target_type
  filter :target_id, label: 'Target id'
  filter :event
  filter :created_at
end
