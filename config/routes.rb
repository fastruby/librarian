Rails.application.routes.draw do
  mount OmbuLabs::Auth::Engine, at: '/', as: 'ombu_labs_auth'

  root to: "links#index"
  resources :links, only: [:index, :show] do
    resources :shares
  end
end
