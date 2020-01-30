Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }, path_names: { sign_in: 'login', sign_out: 'logout' }
  post '/admin/credits/cancel', to: 'admin/credits#cancel', as: :admin_credits_cancel

  ActiveAdmin.routes(self)

  require 'sidekiq/web'
  if Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
  else
    authenticate :user, ->(user) { user.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  resources :overview, only: :index

  get :dashboard, to: 'pages#dashboard'
  get :terms_and_conditions, to: 'pages#terms_and_conditions'

  namespace :api, defaults: { format: :json } do
    get 'verify', to: 'base#verify'
  end

  namespace :broker do
    resources :sign_ups, only: :create
  end

  namespace :enrollment do
    resources :sign_ups, only: %i[new create]
    resources :brokers, only: %i[new create]

    resources :orders, only: %i[edit update] do
      resources :members do
        post :add, to: 'members#add'
      end
      resources :member_imports
      resources :redemption_instructions, only: %i[new create index]

      resources :payments, only: %i[new create] do
        get :confirm, on: :collection
        get :process_order, on: :collection
      end
    end
  end

  namespace :mobile do
    resources :codes, only: %i[show index]
    resources :code_token_urls, only: :index
    get 'codes/first_data_barcode/:id', to: 'codes#barcode'
    get 'codes/first_data_card_image/:id', to: 'codes#card_image'
  end

  resources :organizations do
    get 'codes', on: :member
    namespace :enrollment do
      resources :sign_ups, only: %i[new create]
    end

    scope module: 'organization_portal' do
      resources :commercial_agreements, only: [:index]
      resources :credit_purchases, except: :delete do
        match :void, to: 'credit_purchases#void', via: :patch
        match :pay, to: 'credit_purchases#pay', via: :patch
        match :print, to: 'credit_purchases#print', via: :get
        match :export, to: 'credit_purchases#export', via: :get, on: :collection
      end

      resource :organization, only: %i[edit update]
      get '/users/search', to: redirect('organizations/%{organization_id}/users')
      resources :users do
        match :search, to: 'users#index', via: :post, on: :collection
      end

      resources :credits, only: [:index] do
        get '/advanced_search', to: 'credits#advanced_search', on: :collection
        match :export, to: 'credits#export', via: :get, on: :collection
      end

      resources :member_imports, only: :index
      resources :member_imports do
        match :clear, to: 'member_imports#clear', via: :patch
      end
      resources :redemption_instructions
    end

    resources :plans

    resources :orders, only: %i[index show] do
      match :cancel, to: 'orders#cancel', via: :post
      match :search, to: 'orders#index', via: :get, on: :collection
      match :search, to: 'orders#index', via: :post, on: :collection
    end

    resources :payment_methods, only: %i[edit index] do
      get :confirm, on: :member
    end

    resources :members do
      patch :deactivate, on: :member
      patch :reactivate, on: :member
      post :resend, on: :member
      post :balance_inquiry, on: :member
      get :usages_export, on: :collection

      resources :codes, shallow: true do
        post :lock, on: :member
        post :unlock, on: :member
        patch :deactivate, on: :member
      end
    end

    resources :members, only: :index do
      match :search, to: 'members#index', via: :post, on: :collection

      resources :code, only: :index do
        match :search, to: 'codes#index', via: :post, on: :collection
      end
    end

    get '/members/:id/code/search', to: redirect('organizations/%{organization_id}/members/%{id}/codes')
    get '/orders/search', to: 'orders#index'

    namespace :advanced_search do
      resource :orders, only: :new

      resources :members do
        resource :codes, only: :new
      end
    end
  end

  authenticated :user do
    root 'pages#dashboard', as: :authenticated_root
  end

  devise_scope :user do
    root to: "devise/sessions#new"
  end
end
