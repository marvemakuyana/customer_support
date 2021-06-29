Rails.application.routes.draw do
  resources :conversations do
    resources :posts
  end
  resources :contacts
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
