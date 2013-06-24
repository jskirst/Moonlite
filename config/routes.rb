Metabright::Application.routes.draw do

	resources :sessions
	get '/assets/' => "pages#bad"
	get '/visit/:external_id' => 'sessions#visit', as: 'visit'
	get '/share' => 'sessions#share', as: 'share'
	
	# Custom Challenge Routing
	get '/heroku' => 'paths#marketing'
	
	resources :users do
	  member do
	    get :style
	    put :style
	  end
	end
	match '/retract/:submission_id' => 'users#retract', as: 'retract_submission'
	match '/notifications/:signup_token' => 'users#notifications', as: 'notification_settings'
  match '/professional/:signup_token' => 'users#professional', as: 'professional_settings'
  	
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
		end
	end
	post '/paths/start' => 'paths#start', as: 'start_path'
	
	get '/labs' => 'ideas#ideas', as: 'ideas'
	get '/labs/bugs' => 'ideas#bugs', as: 'bugs'
  get '/labs/idea' => "ideas#idea", as: "new_idea"
  get '/labs/bug' => "ideas#bug", as: "new_bug"
  resources :ideas, path: "labs" do
	  member do
	    get :vote
	  end
	end
	
	match '/paths/:permalink/submission/:submission/' => 'paths#show', as: 'submission_details'
	match '/paths/:permalink/task/:task/' => 'paths#show', as: 'task_details'
	match '/tasks/:task_id/view' => 'paths#drilldown', as: 'task_drilldown'
	match '/submissions/:submission_id/view' => 'paths#drilldown', as: 'submission_drilldown'

  #get '/groups/users' => "users#index"
  resources :groups do
    member do
      get :style
      put :style
      get :join
      delete :leave      
      get :newsfeed
      get :dashboard
      get :sandbox
    end
    
    resources :evaluations, path: "e" do
      member do
        get :review
        get :submit
        get :grade
      end
    end
    
    resources :paths, path: "c"
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
      put :add_stored_resource
      put :archive
      put :complete
      put :took
    end
  end
  get '/submissions/:id/raw' => "tasks#raw", as: "raw"
	
	match '/sections/subregion_options' => "sections#subregion_options", as: 'user_subregion_options'
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
	match '/sections/:id/continue/:session_id' => "sections#continue", as: 'continue_section'
	match '/sections/:id/take/:task_id' => "sections#take", as: 'take_section'
	match '/sections/:id/boss/:task_id/:session_id' => "sections#boss", as: 'boss_section'
	match '/sections/:id/take/:task_id/:session_id' => "sections#take", as: 'take_bonus_section'
	match '/sections/:id/took/:task_id' => "sections#took", as: 'took_section'
	match '/sections/:id/finish/:session_id' => "sections#finish", as: 'finish_section'
	
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
	get '/search' => "search#new"
	post '/search/results' => "search#results"
	post '/search/checkout' => "search#checkout"
	
	match '/newsfeed' => 'pages#newsfeed'
  match '/intro' => 'pages#intro'
  match '/start' => 'pages#start'
  match '/mark_read' => 'pages#mark_read'
  match '/visit/:id' => 'pages#visit'
  match '/mark_help_read' => 'pages#mark_help_read'
  match '/explore', to: 'personas#explore'
  match '/about' => 'pages#about'
  match '/internship' => 'pages#internship'
  match '/employers' => 'pages#employers'
  match '/talentminer' => 'pages#talentminer'
  match '/evaluator' => 'pages#evaluator'
  match '/organization_portal' => 'pages#organization_portal'
  match '/product_form' => 'pages#product_form'
  post  '/opportunity' => 'pages#opportunity'
  match '/product_confirmation' => 'pages#product_confirmation'
  match '/connect' => 'pages#connect'
  match '/tos' => 'pages#tos'
  match '/challenges' => 'pages#challenges'
  match '/preview' => 'pages#preview'
	
	match '/stored_resources' => 'stored_resources#create', via: :post
	match '/stored_resources' => 'stored_resources#create', via: :put
	match '/stored_resources/:id' => 'stored_resources#destroy', via: :delete, as: 'delete_stored_resource'
	
  get '/admin/overview' => 'companies#overview'
  get '/admin/settings' => 'companies#settings'
  get '/admin/users' => 'companies#users'
  get '/admin/funnel' => 'companies#funnel'
  get '/admin/visits' => 'companies#visits'
  put '/admin/users/:id/' => 'companies#users', as: 'admin_update_user'
  get '/admin/user/:id/' => 'companies#user', as: 'admin_user_details'
  get '/admin/paths' => 'companies#paths'
  get '/admin/path/:id' => 'companies#path', as: 'admin_edit_path'
  get '/admin/submissions' => 'companies#submissions'
  put '/admin/submissions/:id' => 'companies#submissions', as: 'admin_update_submission'
  get '/admin/tasks' => 'companies#tasks'
  put '/admin/tasks/:id' => 'companies#tasks', as: 'admin_update_task'
  get '/admin/comments' => 'companies#comments'
  put '/admin/comments/:id' => 'companies#comments', as: 'admin_update_comment'
  get '/admin/styles' => 'companies#styles'
  put '/admin/styles' => 'companies#styles'
  
  match '/locallink' => 'sessions#locallink'
  match '/auth/failure' => 'sessions#auth_failure'
  match '/auth/:provider/callback' => 'sessions#create'
	match '/signin' => 'sessions#new'
	match '/signout' => 'sessions#destroy'
	match '/request_reset' => 'sessions#request_reset'
	match '/send_reset' => 'sessions#send_reset'
	match '/finish_reset' => 'sessions#finish_reset'
	match '/robots.txt' => 'pages#robots'
	
	get '/users/:username/follow' => 'users#follow', as: "follow_user"

  match '/emailtest' => 'pages#email_test', as: 'email'
	match '/send_reset' => 'users#send_reset'
	match '/challenges/:permalink' => 'paths#show', as: 'challenge'
	match '/:username/hovercard' => 'users#hovercard', as: "hovercard_user"
	match '/:username' => 'pages#profile', as: 'profile'
end
