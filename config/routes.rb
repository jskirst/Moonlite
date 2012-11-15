Metabright::Application.routes.draw do
	resources :sessions
	resources :users do
		member do
		  get :home
			get :request_reset
			put :reset_password
			get :edit_role
			put :update_role
		end
	end
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
      get :enroll
			get :continue
		end
	end
	match "/paths/:id/submission/:submission/" => "paths#show", as: "submission_details"
	match "/paths/:id/task/:task/" => "paths#show", as: "task_details"
	resources :sections do
		member do
      get :publish
      get :unpublish
      get :confirm_delete
			get :continue
			post :continue
      get :import_content
      post :preview_content
      post :save_content
      get :html_editor
      get :take
      put :took
      get :launchpad
      put :complete
		end
	end
	resources :enrollments
	resources :tasks do
    member do
      get :vote
      get :add_stored_resource
      put :add_stored_resource
    end
  end
	
	resources :personas do
	  member do
	    get :preview
	  end
	end
	
	resources :stored_resources
  resources :comments
	resources :user_roles
	
	root :to => "pages#home"
  match '/intro' => "pages#intro"
  match '/start' => "pages#start"
  match '/notifications' => "pages#notifications"
  match '/create' => 'pages#create'
  match '/explore', to: "personas#explore"
  match '/about' => "pages#about"
  match '/tos' => "pages#tos"
  match '/challenges' => "pages#challenges"
	
  match '/admin_overview' => 'companies#overview'
  match '/admin_settings' => "companies#settings"
  match '/admin_users' => "companies#users"
  match '/admin_users/:id/' => "companies#users", as: "admin_update_user"
  match '/admin_paths' => "companies#paths"
  match '/admin_paths/:id' => "companies#paths", as: "admin_update_path"
  match '/admin_submissions' => "companies#submissions"
  match '/admin_submissions/:id' => "companies#submissions", as: "admin_update_submission"
  match '/admin_styles' => "companies#styles"
  
  match '/locallink' => 'sessions#locallink'
  match '/auth/failure' => 'sessions#auth_failure'
  match '/auth/:provider/callback' => 'sessions#create'
	match '/signin' => 'sessions#new'
	match '/signout' => 'sessions#destroy'

  match '/emailtest' => 'pages#email_test', as: "email"
	match '/password_reset' => 'users#request_send'
	match '/send_reset' => 'users#send_reset'
end
