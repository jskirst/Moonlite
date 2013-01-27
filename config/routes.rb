Metabright::Application.routes.draw do
	resources :sessions
	
	resources :users
	match '/retract/:submission_id' => 'users#retract', as: 'retract_submission'
	
  resources :paths do
		member do
      get :publish
      get :unpublish
      get :collaborator
      put :collaborator
      put :undo_collaboration
      get :enroll
			get :continue
			get :newsfeed
		end
	end
	
	match '/paths/:permalink/submission/:submission/' => 'paths#show', as: 'submission_details'
	match '/paths/:permalink/task/:task/' => 'paths#show', as: 'task_details'
	match '/tasks/:task_id/view' => 'paths#drilldown', as: 'task_drilldown'
	match '/submissions/:submission_id/view' => 'paths#drilldown', as: 'submission_drilldown'
	
	resources :tasks do
    member do
      get :vote
      post :report
      get :add_stored_resource
      put :add_stored_resource
    end
  end
	
	resources :sections do
		member do
      get :publish
      get :unpublish
      get :confirm_delete
      get :launchpad
      put :complete
		end
	end
	
	match '/sections/:id/continue' => "sections#continue", as: 'start_section'
	match '/sections/:id/continue/:count' => "sections#continue", as: 'continue_section'
	match '/sections/:id/take/:task_id' => "sections#take", as: 'take_section'
	match '/sections/:id/took/:task_id' => "sections#took", as: 'took_section'
	
	resources :enrollments
  
  resources :task_issues, only: [:create]
	
	resources :personas do
	  member do
	    get :preview
	  end
	end
	
  resources :comments
  match '/user_roles/update_user/:user_id' => 'user_roles#update_user', as: 'update_users_role'
	resources :user_roles
	
	root :to => 'pages#home'
	match '/newsfeed' => 'pages#newsfeed'
  match '/intro' => 'pages#intro'
  match '/start' => 'pages#start'
  match '/mark_read' => 'pages#mark_read'
  match '/mark_help_read' => 'pages#mark_help_read'
  match '/create' => 'pages#create'
  match '/explore', to: 'personas#explore'
  match '/about' => 'pages#about'
  match '/tos' => 'pages#tos'
  match '/challenges' => 'pages#challenges'
	
	match '/stored_resources' => 'stored_resources#create', via: :post
	match '/stored_resources' => 'stored_resources#create', via: :put
	match '/stored_resources/:id' => 'stored_resources#destroy', via: :delete, as: 'delete_stored_resource'
	
  match '/admin/overview' => 'companies#overview'
  match '/admin/settings' => 'companies#settings'
  match '/admin/users' => 'companies#users'
  match '/admin/users/:id/' => 'companies#users', as: 'admin_update_user'
  match '/admin/paths' => 'companies#paths'
  match '/admin/paths/:id' => 'companies#paths', as: 'admin_update_path'
  match '/admin/submissions' => 'companies#submissions'
  match '/admin/submissions/:id' => 'companies#submissions', as: 'admin_update_submission'
  match '/admin/tasks' => 'companies#tasks'
  match '/admin/tasks/:id' => 'companies#tasks', as: 'admin_update_task'
  match '/admin/styles' => 'companies#styles'
  
  match '/locallink' => 'sessions#locallink'
  match '/auth/failure' => 'sessions#auth_failure'
  match '/auth/:provider/callback' => 'sessions#create'
	match '/signin' => 'sessions#new'
	match '/signout' => 'sessions#destroy'

  match '/emailtest' => 'pages#email_test', as: 'email'
	match '/password_reset' => 'users#request_send'
	match '/send_reset' => 'users#send_reset'
	
	match '/challenges/:permalink' => 'paths#show', as: 'challenge'
	match '/:username' => 'pages#profile', as: 'profile'
end
