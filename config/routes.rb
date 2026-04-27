Rails.application.routes.draw do
  post "telegram/webhook", to: "telegram/webhooks#create", as: :telegram_webhook

  resource :session, only: %i[ new create destroy ]
  get "/auth/google_oauth2/callback", to: "omniauth_callbacks#google_oauth2"
  get "/auth/naver/callback",         to: "omniauth_callbacks#naver"
  get "/auth/failure",                to: "omniauth_callbacks#failure"
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resource :registration, only: %i[ new create ]

  resource :focus, only: %i[show] do
    resource :settings, controller: "focus/settings", only: %i[show update]
  end

  resources :work_plans do
    member { get :hwpx }
  end
  resources :work_journals
  resources :memos
  resources :posts
  resources :life_infos
  resources :stock_infos, only: %i[index show destroy]
  resources :tech_infos do
    resources :comments, only: %i[ create destroy ]
    resource :reaction, only: %i[ create destroy ], controller: "tech_info_reactions"
    collection do
      get  :export
      post :import
    end
  end

  namespace :admin do
    root "dashboards#index"
    resources :users, only: %i[index show update]
    resources :sessions, only: %i[index]
  end

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "up" => "rails/health#show", as: :rails_health_check

  root "tech_infos#index"
end
