# frozen_string_literal: true

ActiveAdmin.register Notification do
  actions :index, :show, :new, :create

  permit_params :admin_id, :title, :content, :notify_type, :query_users

  filter :admin

  index do
    selectable_column
    id_column
    column :title
    column(:notify_type) { |notification| I18n.t("active_admin.resource.new.#{notification.notify_type}") }
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :content
      row(:notify_type) { |notification| I18n.t("active_admin.resource.new.#{notification.notify_type}") }
      row('Assign Users') do |notification|
        if notification.notify_type == 'all_users'
          I18n.t("active_admin.resource.show.#{notification.notify_type}")
        else
          notification.users.each(&:name)
        end
      end
    end
  end

  form do |_|
    inputs 'Send Notification' do
      notify_type = 'all_users'

      if params[:notification].present?
        notify_type = params[:notification][:notify_type]
        user_ids = params[:notification][:query_users].reject(&:blank?)
      end

      notify_type_options = Notification.notify_types.keys.map { |type| [I18n.t("active_admin.resource.new.#{type}"), type] }

      query_users = User.assign_users(user_ids)

      if query_users.present?
        display_query_users = query_users.map { |user| ["#{user.dashboard_display_name} (#{user.email})", user.id] }
      end

      input :notify_type, as: :radio, collection: notify_type_options, selected: notify_type, label: false
      input :query_users, as: :select, label: 'Assign Users', multiple: true, collection: display_query_users
      hidden_field :admin_id, value: current_admin.id
      inputs :title
      inputs :content
      input :send_to_all_user, as: :boolean, label: 'Send notification with mail', default: false
    end

    actions
  end

  controller do
    include AdminLog

    def create
      build_notification
      load_notify_target

      if @users.present? && @notification.save
        create_notification_relations unless notify_type == 'all_users'
        send_email_to_users
        redirect_to admin_notifications_path
        create_action_log(status: :succeed)
      else
        flash[:notice] = 'Must notify one user.' if @users.blank?
        create_action_log(status: :failed)
        render :new
      end
    end

    private

    def build_notification
      @notification = Notification.new(notification_params)
    end

    def create_notification_relations
      @notification.users << @users
    end

    def notify_type
      params[:notification][:notify_type]
    end

    def load_notify_target
      @users = case notify_type
               when 'all_users'
                 User.all
               when 'all_hosts'
                 User.all_hosts
               when 'hosts_with_existing_bookings'
                 User.hosts_with_existing_bookings
               when 'guests_with_existing_bookings'
                 User.guests_with_existing_bookings
               when 'personal'
                 User.assign_users(query_users_params)
               end
    end

    def query_users_params
      @query_users = params[:notification][:query_users]
    end

    def notification_params
      params[:notification][:notify_type] = notify_type
      params.require(:notification).permit(:admin_id, :title, :content, :send_to_all_user, :notify_type, query_users: [])
    end

    def send_email_to_users
      return unless params[:notification][:send_to_all_user] == '1'

      @users.find_in_batches do |group|
        group.each { |user| NotificationsMailer.notification(@notification, user).deliver_later }
      end
      flash[:notice] = 'Notification Email has been delivered'
    end
  end

  collection_action :query_users do
    query_name = params[:name]&.downcase
    @query_users = User.where('lower(first_name) LIKE ? OR lower(last_name) LIKE ?', "#{query_name}%", "#{query_name}%").order(id: :asc).limit(30).map do |user|
      { id: user.id, text: "#{user.dashboard_display_name} (#{user.email})" }
    end

    render json: @query_users
  end
end
