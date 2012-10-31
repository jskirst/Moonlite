Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == "production"
    provider :facebook, '276612745757646', '3f9879134b5ebde644389bdf958c45cd', :scope => 'email,user_about_me, user_work_history, user_location, user_education_history', :client_options => {:ssl => {:verify => false}}
    provider :google_oauth2, '623155312396.apps.googleusercontent.com', 'BL0dkv0QxDbeCpbs8U24evK1', access_type: 'online', approval_prompt: '', client_options: {ssl: {verify: false}}, scope: "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/plus.me https://www.googleapis.com/auth/userinfo.profile"
  elsif Rails.env == "staging"
    provider :facebook, '276612745757646', '3f9879134b5ebde644389bdf958c45cd', :scope => 'email,user_about_me, user_work_history, user_location, user_education_history', :client_options => {:ssl => {:verify => false}}
    provider :google_oauth2, '623155312396-vire1ln95jqmt1d309n4kcfd6172rg29.apps.googleusercontent.com', '56Y80ANvPBmTajktLygbclvr', access_type: 'online', approval_prompt: '', client_options: {ssl: {verify: false}}, scope: "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/plus.me https://www.googleapis.com/auth/userinfo.profile"
  else
    provider :facebook, '276612745757646', '3f9879134b5ebde644389bdf958c45cd', callback_url: "http://staging.metabright.com/locallink/", client_options: {ssl: {verify: false}}, scope: 'email,user_about_me, user_work_history, user_location, user_education_history'
    provider :google_oauth2, '623155312396-3rh9tel583msldrcugu80l538c9fhvhg.apps.googleusercontent.com', '0RbyjyweKX94Zb4qIogabN_E', access_type: 'online', approval_prompt: '', client_options: {ssl: {verify: false}}, scope: "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/plus.me https://www.googleapis.com/auth/userinfo.profile"
  end
end