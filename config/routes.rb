Rails.application.routes.draw do
  resources :links do
    resources :shares
  end
end
