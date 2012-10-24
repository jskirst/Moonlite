Metabright::Application.routes.draw do
	
	resources :sessions
	resources :users do
		member do
		  get :home
			get :accept
			put :join
			get :set_type
			get :request_reset
			put :reset_password
			get :edit_role
			put :update_role
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
			get :retake
		end
	end
	match "/paths/:id/cp/:cp/" => "paths#show", as: "cp_details"
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
	resources :enrollments do
	  member do
	    put :grade
	  end
	end
	resources :tasks do
    member do
      get :arena
      put :resolve
      get :vote
      put :add_stored_resource
    end
  end
  match '/suggest', to: "tasks#suggest"
	
	resources :personas do
	  member do
	    get :preview
	  end
	end
	match '/explore', to: "personas#explore"
	
	resources :stored_resources
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
  match '/admin', :to => 'companies#show'
  
  match '/locallink',  :to => 'sessions#locallink'
  match '/auth/failure',  :to => 'sessions#auth_failure'
  match '/auth/:provider/callback',  :to => 'sessions#create'
	match '/signin',	:to => 'sessions#new'
	match '/signout',	:to => 'sessions#destroy'
	match '/intro' => "pages#intro"
	match '/start' => "pages#start"
	
	match '/emailtest', :to => 'pages#email_test', as: "email"

  match '/create',:to => 'pages#create'
  
	match '/password_reset', :to => 'users#request_send'
	match '/send_reset', :to => 'users#send_reset'
  
  match '/vanity(/:action(/:id(.:format)))', :controller=>:vanity
end
