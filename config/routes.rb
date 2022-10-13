Rails.application.routes.draw do
  root to: "links#index"
  resources :links, only: [:index, :show] do
    resources :shares
  end
end
