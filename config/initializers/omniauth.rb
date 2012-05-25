Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '276612745757646', '3f9879134b5ebde644389bdf958c45cd',
              :callback_path => "/locallink"
end