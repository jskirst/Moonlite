Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == "production"
    provider :facebook, '276612745757646', '3f9879134b5ebde644389bdf958c45cd', :scope => 'email,user_about_me', :client_options => {:ssl => {:verify => false}}
  else
    provider :facebook, '276612745757646', '3f9879134b5ebde644389bdf958c45cd', :callback_url => "http://www.metabright.com/locallink/", :client_options => {:ssl => {:verify => false}}, :scope => 'email,user_about_me'
  end
end