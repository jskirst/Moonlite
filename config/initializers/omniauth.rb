%w[ facebook google github linkedin ].each do |provider|
  raise "Missing key for #{provider}" if ENV["#{provider.upcase}_KEY"].blank? or ENV["#{provider.upcase}_SECRET"].blank? 
end

Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == "production"
    provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], :scope => 'email,user_about_me, user_work_history, user_location, user_education_history', :client_options => {:ssl => {:verify => false}}
    provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], access_type: 'online', approval_prompt: '', client_options: {ssl: {verify: false}}, scope: "userinfo.email, plus.me, userinfo.profile"
    provider :linkedin_oauth2, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], :scope => 'r_fullprofile r_emailaddress'
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  elsif Rails.env == "staging"
    provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], :scope => 'email,user_about_me, user_work_history, user_location, user_education_history', :client_options => {:ssl => {:verify => false}}
    provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], access_type: 'online', approval_prompt: '', client_options: {ssl: {verify: false}}, scope: "userinfo.email, plus.me, userinfo.profile"
    provider :linkedin_oauth2, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], :scope => 'r_fullprofile r_emailaddress'
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  else
    provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], client_options: {ssl: {verify: false}}, scope: 'email,user_about_me, user_work_history, user_location, user_education_history'
    provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], access_type: 'online', approval_prompt: '', client_options: {ssl: {verify: false}}, scope: "userinfo.email, plus.me, userinfo.profile"
    provider :linkedin_oauth2, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], :scope => 'r_fullprofile r_emailaddress'
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user"
  end
