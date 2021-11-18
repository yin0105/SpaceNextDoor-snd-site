# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  get :why_choose_us, to: 'pages#why_choose_us'
  get :how_it_work, to: 'pages#how_it_work'
  get :need_more_storage, to: 'pages#need_more_storage'
  get :types_of_storage, to: 'pages#types_of_storage'
  get :about, to: 'pages#about'
  get :contact, to: 'pages#contact'
  get :tax_and_law, to: 'pages#tax_and_law'
  get :become_a_host, to: 'pages#become_host'
  get :privacy, to: 'pages#privacy'
  get :ip_policy, to: 'pages#ip_policy'
  get :guest_policy, to: 'pages#guest_policy'
  get :host_policy, to: 'pages#host_policy'
  get :host_standard, to: 'pages#host_standard'
  get :snd_rules, to: 'pages#snd_rules'
  get :terms_of_service, to: 'pages#terms_of_service'
  get :help, to: redirect('https://help.spacenextdoor.com/hc/en-us')
  get :cancellation_policy, to: redirect('https://help.spacenextdoor.com/hc/en-us/articles/115003595487-What-is-our-Cancellation-Policy-')
  get :terms_and_policies, to: 'pages#terms_and_policies'
  get :termination_policy, to: redirect('https://help.spacenextdoor.com/hc/en-us/articles/115005120368-Termination-Policy')
  get :signup_success, to: 'pages#signup_success'
  get :new_enquiry, to: 'new_enquiries#new'
  get :insurance_terms, to: 'pages#insurance_terms'
  get :host_onboarding, to: 'pages#host_onboarding'

  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }, path_names: {
    edit: 'profile'
  }

  root to: 'home#index'

  get '/search(/:region)', to: 'spaces#index', as: :searches
  resources :spaces, only: %i[index show]
  resource :find_out_more, only: %i[new create] do
    get :thank_you
    get :host_submitted
  end

  resource :new_enquiry, only: %i[new create] do
    get :thank_you
  end

  authenticate :user do
    scope :users, module: :users do
      resource :host_contact, only: %i[new create show]
      resource :guest_contact, only: %i[new create show]
      resource :payment_method, only: %i[show new create destroy]
      resource :bank_account, only: %i[show new create]
      resources :favorite_spaces, only: [:index]
      resources :spaces, only: %i[index edit], as: :user_spaces do
        collection do
          get :well_done
          get :query_spaces
        end
      end
      resource :verification, only: %i[show create] do
        resource :verify, only: [:create]
        resource :email, only: %i[create update]
      end
      resource :preferred_phone, only: %i[show update]
      resources :storages, only: %i[new create edit update], as: :user_storages
      resources :ratings, only: [:index] do
        scope module: :ratings do
          collection do
            resources :bulk_updates, only: [:create], as: 'ratings_bulk_update'
          end
        end
      end
      namespace :profile do
        resource :password, only: %i[edit update]
      end
    end
    resources :orders, only: %i[index show new create update] do
      scope module: :orders do
        resources :payments, only: [:create] do
          collection do
            get :well_done
          end
        end
        resources :invoices, only: [:show]
      end
      member do
        get :cancel_long_lease
        get :edit_insurance
        get :edit_transform_long_lease
        patch :update_insurance
        post :update_transform_long_lease
      end
      resource :long_leases, only: :destroy, controller: 'orders/long_leases'
    end

    resources :channels, only: %i[create index show] do
      resources :messages, only: [:create], module: :channels
    end

    resources :notifications, only: [:index]

    resources :spaces, only: [] do
      scope module: :spaces do
        resource :favorite, only: %i[create destroy]
        resource :shelf, only: %i[create destroy]
      end
      resources :ratings, only: [:update]
    end

    resources :profiles, only: [] do
      resources :ratings, only: [:update]
    end
  end

  authenticate :admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :api, defaults: { format: :json } do
    resources :images, only: [:create]
    resources :user_avatars, only: [:create]
  end

  mount Styleguide::Engine, at: '/styleguide' if Rails.env.development?

  match '*unmatched', to: 'errors#route_not_found', via: :all unless Rails.env.development?
end
