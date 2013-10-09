Metabright::Application.routes.draw do

	resources :sessions
	
	resources :users do
	  member do
	    get :style
	    patch :style
	    get :possess
	    get :notifications
	    patch :notifications
	    get :professional
	    patch :professional
	  end
	end
	get '/users/subregion' => 'users#subregion', as: "subregion_users"
	get '/retract/:submission_id' => 'users#retract', as: 'retract_submission'
  # get '/notifications/:signup_token' => 'users#notifications', as: 'notification_settings'
  #   get '/professional/:signup_token' => 'users#professional', as: 'professional_settings'
  	
  resources :paths do
		member do
		  get :style
		  put :style
      get :publish
      get :unpublish
      get :collaborator
      put :collaborator
      put :undo_collaboration
      get :enroll
			get :continue
			get :newsfeed
			get :join
			get :leaderboard
			patch :upload
		end
		
		#post '/paths/start' => 'paths#start', as: 'start_path'
		collection do
		  post :start
		end
	end
	
	
	get '/labs' => 'ideas#ideas', as: 'ideas'
	get '/labs/bugs' => 'ideas#bugs', as: 'bugs'
  get '/labs/idea' => "ideas#idea", as: "new_idea"
  get '/labs/bug' => "ideas#bug", as: "new_bug"
  resources :ideas, path: "labs" do
	  member do
	    get :vote
	  end
	end
	
	get '/paths/:permalink/submission/:submission/' => 'paths#show', as: 'submission_details'
	get '/paths/:permalink/task/:task/' => 'paths#show', as: 'task_details'
	get '/tasks/:task_id/view' => 'paths#drilldown', as: 'task_drilldown'
	get '/submissions/:submission_id/view' => 'paths#drilldown', as: 'submission_drilldown'
  
  get '/g/coupon' => 'groups#coupon', as: 'coupon'
  resources :groups, path: "g" do
    member do
      get :checkout
      put :checkout
      get :confirmation
      get :style
      put :style
      get :join
      delete :leave      
      get :newsfeed
      get :dashboard
      get :account
      get :sandbox
      get :request_invite
      post :invite
      get :close
      put :close
    end
    
    collection do
      get :purchased
    end
    
    resources :evaluations, path: "e" do
      member do
        get :review
        get :submit
        get :grade
        put :save
      end
    end
    
    resources :paths, path: "c"
    
    resource :search, path: "s", controller: "search" do
      member do
        get :checkout
        put :purchase
        get :purchases
      end
    end
  end
  get '/e/:evaluation_id/continue/:path_id' => 'evaluations#continue', as: "continue_evaluation"
  get '/e/:evaluation_id/continue/:path_id/:task_id' => 'evaluations#continue', as: "continue_task_evaluation"
  put '/e/:evaluation_id/answer/:task_id' => 'evaluations#answer', as: "answer_evaluation"
  get "/e/:permalink" => "evaluations#take", as: "take_group_evaluation"
	
	resources :tasks do
    member do
      get :vote
      post :report
      get :add_stored_resource
      patch :add_stored_resource
      put :archive
      put :complete
      patch :took
    end
  end
  get '/submissions/:id/raw' => "tasks#raw", as: "raw"
	
	get '/sections/subregion_options' => "sections#subregion_options", as: 'user_subregion_options'
	resources :sections do
		member do
      get :publish
      get :unpublish
      get :confirm_delete
      get :launchpad
      put :complete
		end
	end
	
	get '/sections/:id/continue' => "sections#continue", as: 'start_section'
	get '/sections/:id/continue/:session_id' => "sections#continue", as: 'continue_section'
	get '/sections/:id/take/:task_id' => "sections#take", as: 'take_section'
	get '/sections/:id/boss/:task_id/:session_id' => "sections#boss", as: 'boss_section'
	get '/sections/:id/take/:task_id/:session_id' => "sections#take", as: 'take_bonus_section'
	patch '/sections/:id/took/:task_id' => "sections#took", as: 'took_section'
	get '/sections/:id/finish/:session_id' => "sections#finish", as: "finish_section"
	
	resources :enrollments
  
  resources :task_issues, only: [:create]
	
	resources :personas do
	  member do
	    get :preview
	  end
	end
	
  resources :comments
  get '/user_roles/update_user/:user_id' => 'user_roles#update_user', as: 'update_users_role'
  #post '/user_roles/update_user/:user_id' => 'user_roles#update_user', as: 'update_users_role'
	resources :user_roles
	
	root :to => 'pages#home'
	
	get '/newsfeed' => 'pages#newsfeed'
  get '/intro' => 'pages#intro'
  get '/start' => 'pages#start'
  get '/mark_read' => 'pages#mark_read'
  get '/mark_help_read' => 'pages#mark_help_read'
  get '/explore', to: 'personas#explore'
  get '/about' => 'pages#about'
  get '/internship' => 'pages#internship'
  get '/evaluator' => 'pages#evaluator'
  get '/pricing' => 'pages#pricing', as: 'pricing'
  get '/organization_portal' => 'pages#organization_portal'
  get '/product_form' => 'pages#product_form'
  get '/tos' => 'pages#tos'
  get '/challenges' => 'pages#challenges'
  #get '/preview' => 'pages#preview'
	
	patch '/stored_resources' => 'stored_resources#create'
	delete '/stored_resources/:id' => 'stored_resources#destroy', as: 'delete_stored_resource'
	
	scope '/admin' do
    get '/overview' => 'admin#overview', as: "admin_overview"
    get '/settings' => 'admin#settings', as: "admin_settings"
    get '/users' => 'admin#users', as: "admin_users"
    get '/funnel' => 'admin#funnel', as: "admin_funnel"
    get '/visits' => 'admin#visits', as: "admin_visits"
    get '/visit/:visit_id' => 'admin#visit', as: "admin_visit"
    put '/users/:id/' => 'admin#users', as: 'admin_update_user'
    get '/user/:id/' => 'admin#user', as: 'admin_user_details'
    get '/paths' => 'admin#paths', as: "admin_paths"
    get '/path/:id' => 'admin#path', as: 'admin_edit_path'
    get '/submissions' => 'admin#submissions', as: "admin_submissions"
    put '/submissions/:id' => 'admin#submissions', as: 'admin_update_submission'
    get '/tasks' => 'admin#tasks', as: "admin_tasks"
    put '/tasks/:id' => 'admin#tasks', as: 'admin_update_task'
    get '/comments' => 'admin#comments', as: "admin_comments"
    put '/comments/:id' => 'admin#comments', as: 'admin_update_comment'
    get '/groups' => 'admin#groups', as: "admin_groups"
    get '/groups/:group_id' => 'admin#group', as: "admin_group"
    get '/email' => 'admin#email', as: "admin_email"
    post '/email' => 'admin#email', as: "admin_send_email"
  end 
  
  get '/streaming' => 'pages#streaming'
  get '/locallink' => 'sessions#locallink'
  get '/auth/failure' => 'sessions#auth_failure'
  get '/auth/:provider/callback' => 'sessions#create'
	get '/signin' => 'sessions#new'
	delete '/signout' => 'sessions#destroy'
	get '/request_reset' => 'sessions#request_reset'
	get '/send_reset' => 'sessions#send_reset'
	get '/finish_reset' => 'sessions#finish_reset'
	get '/robots.txt' => 'pages#robots'
  get '/sitemap.xml.gz' => 'pages#sitemap'
	
	get '/users/:username/follow' => 'users#follow', as: "follow_user"

  get '/emailtest' => 'pages#email_test', as: 'email'
	get '/send_reset' => 'users#send_reset'
	get '/challenges/:permalink' => 'paths#show', as: 'challenge'
	get '/:username/hovercard' => 'users#hovercard', as: "hovercard_user"
	get '/:username' => 'pages#profile', as: 'profile'
end
