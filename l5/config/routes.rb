Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :todos

  resources :users do
    collection do
      post "login"
    end
  end
end
