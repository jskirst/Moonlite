class LeaderboardsController < ApplicationController
  before_filter :authenticate
	before_filter :admin_or_company_admin, :only => [:new, :create]
  before_filter :is_enabled

  def index
			@leaderboards = []
			@leaderboards << ["overall", Leaderboard.get_overall_leaderboard(current_user.company)]
			
			@categories = current_user.company.categories
			@categories.each do |c|
				@leaderboards << [c.id, Leaderboard.get_leaderboard_for_category(c)]
			end
	end
  
  def new
  end

  def create
    unless params[:password] == "alltheaboveplease"
      flash[:error] = "Incorrect reset password."
      render "new" and return
    end
    
    Leaderboard.reset_leaderboard
    render "finished"
  end
  
  private
		def admin_or_company_admin
			redirect_to(root_path) unless (current_user.admin? || current_user.company_admin?)
		end
    
    def is_enabled
      unless current_user.company.enable_leaderboard
        flash[:error] = "This feature is not currently enabled for your use."
        redirect_to root_path
      end
    end
end
