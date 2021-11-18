# frozen_string_literal: true

ActiveAdmin.register Payment, as: 'FailedTransaction' do
  menu parent: 'Transactions'
  actions :index

  controller do
    def scoped_collection
      end_of_association_chain.where(status: %i[failed retry])
    end
  end

  filter :user
  filter :service_start_at
  filter :service_end_at
  filter :failed_at

  index title: 'Failed / Retry Transactions' do
    # column :guest_id
    column :guest
    # column :host_id
    column :host
    column :order
    # column :order_days
    column :identity
    column :period do |resource|
      "#{resource.service_start_at.strftime('%b %d')} - #{resource.service_end_at.strftime('%b %d')}(#{resource.period})"
    end
    column :amount do |resource|
      resource.amount.format
    end
    column :host_rent do |resource|
      resource.host_rent.format
    end
    column :guest_service_fee do |resource|
      resource.guest_service_fee.format
    end
    column :host_service_fee do |resource|
      resource.host_service_fee.format
    end
    column :error_message do |resource|
      pre resource.error_message
    end
    column(:status) { |resource| status_tag resource.status }
  end
end
