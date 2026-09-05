Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]
  root "dashboard#index"
  resources :plans, only: %i[create update]
  resources :goals, only: %i[create update] do
    resources :tasks, only: :create
  end
  post "plans/:plan_id/goals" => "goals#create", as: :plan_goals
  post "plans/:plan_id/check_ins" => "check_ins#create", as: :plan_check_ins
  post "plans/:plan_id/exports" => "exports#create", as: :plan_exports
  resources :tasks, only: :update
  get "exports/:id/download" => "exports#download", as: :download_export
  get "up" => "rails/health#show", as: :rails_health_check
end
