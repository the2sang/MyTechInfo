Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resource :registration, only: %i[ new create ]

  resources :posts
  resources :tech_infos

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end
