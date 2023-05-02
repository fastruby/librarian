Rails.application.routes.draw do
  root to: "links#index"
  resources :links, only: [:index, :show] do
    resources :shares
    get '/shares/:id/clone', to: 'shares#clone', as: "clone"
  end
end
