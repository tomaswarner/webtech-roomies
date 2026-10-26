Rails.application.routes.draw do
  root "pages#home"

  resource :acting_user, only: :update

  resources :neighborhoods
  resources :amenities, except: :show

  resources :properties do
    resources :listings, only: [ :new, :create ]
    resources :reviews, only: [ :new, :create ]
  end

  resources :listings, only: [ :index, :show, :edit, :update, :destroy ] do
    resources :applications, only: :create
  end

  resources :applications, only: [ :index, :show, :update ] do
    resources :visits, only: [ :new, :create ]
  end

  resources :visits, only: [ :edit, :update ]

  resources :reviews, only: [ :edit, :update, :destroy ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
