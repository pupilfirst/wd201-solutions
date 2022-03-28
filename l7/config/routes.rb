Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :todos

  resources :users do
    collection do
      post "login"
    end
  end
end
