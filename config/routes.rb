Rails.application.routes.draw do
  post "telegram/webhook", to: "telegram/webhooks#create", as: :telegram_webhook

  resource :session, only: %i[ new create destroy ]
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resource :registration, only: %i[ new create ]

  resources :work_plans do
    member { get :hwpx }
  end
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

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "up" => "rails/health#show", as: :rails_health_check

  root "tech_infos#index"
end
