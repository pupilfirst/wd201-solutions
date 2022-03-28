Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :todos

  resources :users

  # The user session can be treated as a singular resource.
  # Learn more about these here: https://guides.rubyonrails.org/routing.html#singular-resources
  resource :session

  root to: "home#index"
end
