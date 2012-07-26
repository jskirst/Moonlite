class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  
  before_filter :analyze_visitor
  before_filter :determine_enabled_features
  use_vanity :current_user
  
  private
    def get_referrer_domain
      #referrer_url = request.env['HTTP_REFERER']
      
      
      # if referrer_url
        # domain = referrer_url.split('/')[2]
        # if domain
          # raise domain.split(".")[-2]
        # end
      # end
    end
end
