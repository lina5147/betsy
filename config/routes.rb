Rails.application.routes.draw do
  get 'categories/index'
  resources :products
  resources :categories, only:[:index]

  root to: "products#index"

  # Omniauth Login Route
  get "/auth/github", as: "github_login"
  # Omniauth Github callback route
  get "/auth/:provider/callback", to: "users#create", as: "omniauth_callback"

  # User routes
  delete "/logout", to: "users#destroy", as: "logout"
  get "/users/current", to: "users#current", as: "current_user"

  # Nested Route (not tested) - to link to separate page for current user products
  #get "/user/:user_id/products", to: "products#index", as: "current_user_products"

  get 'carts/:id', to: "carts#show", as: "cart"
end
