Rails.application.routes.draw do

  root 'pages#index'
  get '/contact' => 'pages#contact'
  get '/privacy' => 'pages#privacy'
  get '/terms' => 'pages#terms'
  get '/account_activation/:id' => 'pages#confirm_email'

  namespace :api do
    namespace :v1 do
      devise_for :users
      post 'users/fb_connect' => 'registrations#fb_connect'
      post 'users/find' => 'users#index'
      post 'users/ban' => 'users#ban'
      post 'users/edit' => 'users#edit'
      post 'users/new_password' => 'users#new_password'
      post 'users/sign_up' => 'registrations#create'
      post 'users/resend_confirmation_code' => 'users#resend_confirmation_code'
      post 'users/check' => 'users#check'
      get 'friends/:type' => 'friends#index'
      post 'friends/' => 'friends#create'
      delete 'friends/:id' => 'friends#destroy'
      resources :tinks, :defaults => { :format => 'json' }
    end
  end


#namespace :api, defaults: { format: "json" } do


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
