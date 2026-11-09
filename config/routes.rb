Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: [ :new, :create ]
  resource :profile, only: [ :show, :edit, :update ]

  root "pages#home"

  resources :neighborhoods
  resources :amenities, except: :show

  resources :properties do
    resources :listings, only: [ :new, :create ]
    resources :reviews, only: [ :new, :create ]
  end

  resources :listings, only: [ :index, :show, :edit, :update, :destroy ] do
    resources :applications, only: :create
    resources :reports, only: [ :new, :create ]
  end

  resources :applications, only: [ :index, :show, :update ] do
    resources :visits, only: [ :new, :create ]
  end

  resources :visits, only: [ :edit, :update ]

  resources :reviews, only: [ :edit, :update, :destroy ]

  resources :reports, only: [ :index, :update ]

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :listings, only: [ :index, :show ]
      match "(*unmatched)", to: "base#route_not_found", via: :all, format: false
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
