# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 1

  actions :all, except: %i[new create destroy]

  member_action :login_as, method: :get do
    session[:_admin_mode] = true
    sign_in(:user, resource, bypass: true)
    create_action_log(status: :succeed)
    redirect_to root_path
  end

  controller do
    include AdminLog

    def csv_filename
      "Users-#{Time.zone.today}.csv"
    end

    def update
      super do |success_response, fail_response|
        if success_response.present?
          create_action_log(status: :succeed)
        elsif fail_response.present?
          create_action_log(status: :failed)
        end
      end
    end
  end

  scope :all, default: true
  scope :confirmed
  scope :unconfirmed
  scope :phone_confirmed
  scope :phone_unconfirmed

  filter :first_name
  filter :last_name
  filter :email
  filter :created_at

  permit_params :first_name, :last_name, :email, :password, :password_confirmation

  index download_links: [:csv] do
    selectable_column
    id_column

    column :name do |user|
      link_to user.name, admin_user_path(user)
    end
    column :gender
    column :email
    column :provider
    column :created_at do |user|
      user&.created_at
    end
    column do |user|
      link_to 'Login', login_as_admin_user_path(user)
    end

    actions
  end

  csv do
    column :id
    column :name
    column :gender
    column :email
    column :provider
    column :created_at do |user|
      I18n.l(user&.created_at, format: :active_admin_date)
    end
  end

  show do
    attributes_table do
      row :id
      row :email
      row :phone
      row :preferred_phone
      row :first_name
      row :last_name

      row :created_at
      row :updated_at
    end

    panel 'Host alternate contact' do
      if user.contacts.find_by(type: 'host').present?
        attributes_table_for user.contacts.find_by(type: 'host') do
          row :name
          row :email
          row :phone
        end
      else
        para 'None', class: 'panel_well'
      end
    end

    panel 'Guest alternate contact' do
      if user.contacts.find_by(type: 'guest').present?
        attributes_table_for user.contacts.find_by(type: 'guest') do
          row :name
          row :email
          row :phone
        end
      else
        para 'None', class: 'panel_well'
      end
    end

    panel 'Owned spaces' do
      table_for user.spaces do
        column :id do |space|
          link_to space.id, admin_space_path(space)
        end
        column :name do |space|
          link_to space.name, admin_space_path(space)
        end
      end
    end

    panel 'Bank Account' do
      if user.bank_account.present?
        attributes_table_for user.bank_account do
          row :country
          row :bank_code
          row :account_name
          row :account_number
        end
      else
        para 'This user has not filled in his/her bank account information yet.', class: 'panel_well'
      end
    end

    panel 'Actions' do
      para class: 'panel_well' do
        link_to 'Login as this user', login_as_admin_user_path(user)
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :first_name, input_html: { autocomplete: 'off' }
      input :last_name, input_html: { autocomplete: 'off' }
    end

    f.inputs 'Change Email' do
      input :email
    end

    f.inputs 'Change password' do
      input :password, hint: 'leave this blank if you don\'t want to change the password'
      input :password_confirmation
    end

    f.actions
  end
end
