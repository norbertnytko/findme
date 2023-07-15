Rails.application.routes.draw do
  resources :one_pagers, param: :slug, only: [:show, :edit, :update]
end
