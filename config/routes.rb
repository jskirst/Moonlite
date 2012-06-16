SampleApp::Application.routes.draw do
	get ":id" => "users#show", :id => /\d+/
  #post "sections/generate" => "sections#generate"
  
	resources :sessions
	resources :users do
		member do
			get :accept
			put :join
			get :set_type
			get :request_reset
			put :reset_password
			get :edit_role
			put :update_role
			get :puzzle
		end
	end
	resources :tours do
		member do
			get :admin_tour
			get :user_tour
		end
	end
	resources :companies do
		member do
			get :join
			put :accept
			get :edit_roles
		end
	end
	resources :custom_styles
  resources :paths do
		member do
      get :dashboard
      get :publish
      get :unpublish
      get :change_company
      put :update_roles
      get :collaborators
      put :collaborator
      get :undo_collaboration
      get :jumpstart
			get :continue
      get :finish
		end
	end
	resources :sections do
		member do
      get :publish
      get :unpublish
      get :confirm_delete
			get :continue
      get :results
      put :reorder_tasks
      get :research
      get :questions
      post :generate
      post :review
      post :bulk_tasks
      get :import_content
      post :preview_content
      post :save_content
      get :html_editor
		end
	end
	resources :enrollments
	resources :tasks do
    member do
      get :suggest
      put :resolve
    end
  end
	resources :achievements
	resources :user_achievements
	resources :info_resources
	resources :user_transactions
	resources :rewards do
		member do
			get :review
			get :purchase
		end
	end
  resources :comments
  resources :leaderboards
	resources :categories
	resources :phrases
	resources :user_roles do
    member do
      get :invite
    end
  end
	
	root 				:to => "pages#home"
	
  match '/usage', :to => 'users#usage_reports'
  
  match '/outndelete',  :to => 'sessions#out_and_delete'
  match '/locallink',  :to => 'sessions#locallink'
  match '/auth/failure',  :to => 'sessions#auth_failure'
  match '/auth/:provider/callback',  :to => 'sessions#create'
	match '/signin',	:to => 'sessions#new'
	match '/signout',	:to => 'sessions#destroy'
	
	match '/about',		:to => 'pages#about'
	match '/help',		:to => 'pages#help'
	match '/invitation',:to => 'pages#invitation'

  match '/all_paths',	:to => 'pages#explore'
  match '/explore',:to => 'pages#explore'
  match '/create',:to => 'pages#create'
  
	match '/dashboard',	:to => 'reports#dashboard'
	match '/details',	:to => 'reports#details'
	match '/marketplace',:to => 'paths#marketplace'
	
	match '/retrieve', :to => 'info_resources#retrieve'
	
	match '/password_reset', :to => 'users#request_send'
	match '/send_reset', :to => 'users#send_reset'
  
  match '/vanity(/:action(/:id(.:format)))', :controller=>:vanity
  
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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
