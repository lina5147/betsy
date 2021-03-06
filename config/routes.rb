Rails.application.routes.draw do

  resources :products do
    resources :reviews, only:[:create]
  end
  post "/products/:id/add_to_cart,", to: "products#add_to_cart", as: "add_to_cart"


  resources :categories, :users, only:[:index] do
    resources :products, only:[:index]
  end

  resources :categories, only:[:create]

  root to: "products#index"

  # Omniauth Login Route
  get "/auth/github", as: "github_login"
  # Omniauth Github callback route
  get "/auth/:provider/callback", to: "users#create", as: "omniauth_callback"

  delete "/logout", to: "users#destroy", as: "logout"
  get "/users/current", to: "users#current", as: "current_user"
  get "/users/current/fulfillment", to: "users#fulfillment", as: "current_user_fulfillment"

  get 'carts/:id', to: "carts#show", as: "cart"
  get 'carts/:id/purchase', to: "carts#purchase_form", as: "purchase_form"
  patch 'carts/:id', to: "carts#purchase"
  get 'carts/:id/confirmation', to: "carts#view_confirmation", as: "view_confirmation"
  get 'carts/:id/details', to: 'carts#order_details', as: 'order_details'

  resources :cartitems, only:[:destroy]

  post 'cartitems/:id/add', to: "cartitems#add_qty", as: "add"
  post 'cartitems/:id/reduce', to: "cartitems#reduce_qty", as: "reduce"
  post 'cartitems/:id', to: 'cartitems#update_status', as: 'update_status'

end
