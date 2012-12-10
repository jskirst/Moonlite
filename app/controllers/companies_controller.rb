class CompaniesController < ApplicationController
  before_filter :authenticate
  before_filter { raise "ACCESS DENIED" unless @enable_administration }
  
  def overview
    @user_count = User.count
    @ct_count = CompletedTask.count
    @submission_count = SubmittedAnswer.count
    @vote_count = Vote.count
    @comment_count = Comment.count
    
    @new_user_count = User.where("DATE(created_at) = DATE(?)", Time.now).count
    @new_ct_count = CompletedTask.where("DATE(created_at) = DATE(?)", Time.now).count
    @new_submission_count = SubmittedAnswer.where("DATE(created_at) = DATE(?)", Time.now).count
    @new_vote_count = Vote.where("DATE(created_at) = DATE(?)", Time.now).count
    @new_comment_count = Comment.where("DATE(created_at) = DATE(?)", Time.now).count
  end
  
  def users
    if request.get?
      if params[:search]
        search = "%#{params[:search]}%"
        @users = User.paginate(page: params[:page], conditions: ["name ILIKE ? or email ILIKE ?", search, search])
      else
        @users = User.paginate(page: params[:page], order: "earned_points DESC")
      end
    else
      status = params[:lock] == "true" ? true : false
      @user = User.find(params[:id])
      @user.update_attribute(:is_locked, status)
      render json: { status: status }
    end
  end
  
  def paths
    if request.get?
      if params[:search]
        @paths = current_company.all_paths.paginate(page: params[:page], conditions: ["name ILIKE ?", "%#{params[:search]}%"])
      else
        @paths = current_company.all_paths.paginate(page: params[:page])
      end
    else
      status = params[:approve] == "true" ? true : false
      @path = Path.find(params[:id])
      @path.update_attribute(:is_approved, status)
      render json: { status: status }
    end
  end
  
  def submissions
    if request.get?
      if params[:search]
        @submissions = SubmittedAnswer.paginate(page: params[:page], conditions: ["content ILIKE ? and is_reviewed = ?", "%#{params[:search]}%", false])
      else
        @submissions = SubmittedAnswer.paginate(page: params[:page], conditions: ["is_reviewed = ?", false])
      end
      render "submissions"
    else
      @submission = SubmittedAnswer.find(params[:id])
      @submission.update_attribute(:is_reviewed, true)
      render json: { status: "success" }
    end
  end
    
  def styles
    @custom_style = current_company.custom_style
    unless request.get?
      if @custom_style.update_attributes(params[:custom_style])
        flash.now[:notice] = "Custom style updated."
      end
    end
  end
end
