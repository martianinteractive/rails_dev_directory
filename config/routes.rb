RailsDevDirectory::Application.routes.draw do
  root :to => 'my/dashboard#show'
  resources :contact_messages
  
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login
  match 'register' => 'users#new', :as => :signup
  
  resource :session
  resources :password_resets

  match 'states/:state' => 'states#show'
  
  resources :top_cities

  match "providers/by_location" => 'providers#by_location'
  match "location/:country" => 'countries#show', :as => :location
  match "location/us/:state" => 'states#show', :as => :us_provider
  
  resource :home
  resource :provider_directory, :controller => "provider_directory"
  resources :providers, :shallow => true do
    collection do
      get :search
    end
    
    resources :endorsements
  end  
  resources :rfps
  resources :pages, :requirements => { :id => /.*/}
  
  # Provider admin routes
  match 'my' => 'my/dashboard#show'
  
  namespace :my do
    resource :dashboard, :controller => 'dashboard'
    resource :provider, :as => :provider
    resources :portfolio_items
    resources :endorsement_requests
    resources :users
    resources :endorsements do 
      collection do
        put :sort
        put :update_all
      end
    end
    resources :requests
  end
  
  # Admin routes
  
  match 'admin' => 'admin/dashboard#show'
  match '/admin/change_password' => 'admin/users#change_password', :as => :change_password

  namespace :admin do
    resource :dashboard, :controller => 'dashboard'
    resources :services
    resources :users do
      member do
        get :take_control
        put :resend_welcome
      end
    end
    resources :portfolio_items
    resources :rfps
    resources :endorsements
    resources :providers do
      resources :users
      resources :portfolio_items
      resources :requests
      resources :endorsements
    end
    resources :pages
    resource :csv
    resources :top_cities do
      collection do
        put :sort
      end
    end
  end
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
