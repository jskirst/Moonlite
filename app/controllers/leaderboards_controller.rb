class LeaderboardsController < ApplicationController
  before_filter :authenticate
	before_filter :admin_or_company_admin, :only => [:new, :create]
  before_filter :is_enabled

  def index
    previous_board = Leaderboard.first
    latest_date = previous_board.nil? ? Time.now : previous_board.created_at
    @leaderboards = Leaderboard.find(:all, :conditions => ["leaderboards.created_at = ?", latest_date], :order => "score DESC")
  end
  
  def new
  end

  def create
    unless params[:password] == "alltheaboveplease"
      flash[:error] = "Incorrect reset password."
      render "new" and return
    end
    
    date ||= Time.now
    users = User.all
    users.each do |u|
      completed_tasks = u.completed_tasks.size
      score = u.earned_points
      Leaderboard.create!(:user_id => u.id, :completed_tasks => completed_tasks, :score => score, :created_at => date)
    end
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
