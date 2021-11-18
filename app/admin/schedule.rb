# frozen_string_literal: true

ActiveAdmin.register Schedule do
  actions :index

  controller do
    def scoped_collection
      end_of_association_chain.preload(:schedulable)
    end
  end

  member_action :perform, method: :post do
    resource.perform

    flash[:notice] = resource.event.split('_').join(' ').upcase + ' perform success.'
  end

  scope :all, default: true
  scope :scheduled
  scope :completed

  filter :schedulable_type
  filter :schedulable_id
  filter :status
  filter :schedule_at

  index do
    id_column
    column :event do |resource|
      I18n.t("schedule.#{resource.schedulable_type.pluralize.downcase}.#{resource.event}", default: resource.event.titleize)
    end
    column :schedulable
    column(:status) { |schedule| status_tag schedule.status }
    column :schedule_at

    unless Rails.env.production?
      column :action do |resource|
        @upcoming_schedule ||= Schedule.scheduled.order(schedule_at: :asc).first

        if resource == @upcoming_schedule
          link_to 'Perform', '#', class: 'perform-admin-schedule',
                                  data: { request_path: perform_admin_schedule_path(resource) }
        end
      end
    end
  end
end
