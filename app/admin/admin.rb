# frozen_string_literal: true

ActiveAdmin.register Admin do
  menu priority: 10

  permit_params :email, :password, :password_confirmation, :type

  controller do
    def update
      if resource.update(admin_params)
        flash[:notice] = 'Admin was successfully updated.'
        create_action_log(status: :succeed)
        redirect_to admin_admins_path
      else
        create_action_log(status: :failed)
        render :edit
      end
    end

    private

    def admin_params
      @admin_params = permitted_params[:admin]
      @admin_params.delete :password if @admin_params[:password].blank?
      @admin_params.delete :password_confirmation if @admin_params[:password_confirmation].blank?
      @admin_params
    end
  end

  controller do
    include AdminLog

    def create
      super do |success_response, fail_response|
        if success_response.present?
          create_action_log(status: :succeed)
        elsif fail_response.present?
          create_action_log(status: :failed)
        end
      end
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :type do |admin|
      admin.type.split('::').last
    end
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs 'Admin Details' do
      f.input :email
      f.input :password, required: false
      f.input :password_confirmation
      f.input :type, as: :radio, collection: Admin::ROLES.map { |role| [role.split('::').last, role] }
    end
    f.actions
  end
end
