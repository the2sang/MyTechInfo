Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resource :registration, only: %i[ new create ]

  resources :memos
  resources :posts
  resources :tech_infos do
    resources :comments, only: %i[ create destroy ]
    resource :reaction, only: %i[ create destroy ], controller: "tech_info_reactions"
    collection do
      get  :export
      post :import
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "tech_infos#index"
end
