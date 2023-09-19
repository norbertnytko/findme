Rails.application.routes.draw do
  root to: 'pages#index'

  resources :one_pagers, param: :slug do
    resources :links, only: [:create, :update, :destroy, :edit] do
      collection do
        get 'fields'
        get 'discard_fields'
      end
    end
  end

  mount RailsEventStore::Browser => "/res" if Rails.env.development?
end
