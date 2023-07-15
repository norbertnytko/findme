Rails.application.routes.draw do
  resources :one_pagers, param: :slug, only: [:show, :edit, :update] do
    resources :links, only: [:create, :update, :destroy]
  end

  mount RailsEventStore::Browser => "/res" if Rails.env.development?
end
