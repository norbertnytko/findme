Rails.application.routes.draw do
  resources :one_pagers, only: [:show, :edit, :update]
end
