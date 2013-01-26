class CompaniesController < ApplicationController
  before_filter :authenticate
  before_filter { raise "ACCESS DENIED" unless @enable_administration }
  
  def overview
    admin_users = [0]
    unless params[:admin]
      admin_users = User.joins(:user_role).where("user_roles.enable_administration = ?", true).to_a.collect &:id
    end

    @users                  = User.where("id not in (?)", admin_users).count
    @arena_answers          = CompletedTask.joins(:task).where("user_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::MULTIPLE).count
    @creative_answers       = CompletedTask.joins(:task).where("user_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::CREATIVE).count
    @task_answers           = CompletedTask.joins(:task).where("user_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::CHECKIN).count
    @arena_questions        = Task.where("creator_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::MULTIPLE).count
    @creative_questions     = Task.where("creator_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::CREATIVE).count
    @task_questions         = Task.where("creator_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::CHECKIN).count
    @votes                  = Vote.where("user_id not in (?)", admin_users).count
    @comments               = Comment.where("user_id not in (?)", admin_users).count
    
    @new_users              = User.where("id not in (?)", admin_users).where("DATE(created_at) = DATE(?)", Time.now).count
    @new_arena_answers      = CompletedTask.joins(:task).where("user_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::MULTIPLE).where("DATE(completed_tasks.created_at) = DATE(?)", Time.now).count
    @new_creative_answers   = CompletedTask.joins(:task).where("user_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::CREATIVE).where("DATE(completed_tasks.created_at) = DATE(?)", Time.now).count
    @new_task_answers       = CompletedTask.joins(:task).where("user_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::CHECKIN).where("DATE(completed_tasks.created_at) = DATE(?)", Time.now).count
    @new_arena_questions    = Task.where("creator_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::MULTIPLE).where("DATE(created_at) = DATE(?)", Time.now).count
    @new_creative_questions = Task.where("creator_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::CREATIVE).where("DATE(created_at) = DATE(?)", Time.now).count
    @new_task_questions     = Task.where("creator_id not in (?)", admin_users).where("tasks.answer_type = ?", Task::CHECKIN).where("DATE(created_at) = DATE(?)", Time.now).count
    @new_votes              = Comment.where("user_id not in (?)", admin_users).where("DATE(created_at) = DATE(?)", Time.now).count
    @new_comments           = Vote.where("user_id not in (?)", admin_users).where("DATE(created_at) = DATE(?)", Time.now).count
  end
  
  def users
    if request.get?
      if params[:search]
        search = "%#{params[:search]}%"
        @users = User.paginate(page: params[:page], conditions: ["name ILIKE ? or email ILIKE ? and is_fake_user = ?", search, search, false])
      else
        @sort = params[:sort] || "earned_points"
        @users = User.paginate(page: params[:page], conditions: ["is_fake_user = ?", false], order: "#{@sort} DESC").includes(:user_role)
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
  
  def tasks
    if request.get?
      if params[:search]
        @tasks = Task.paginate(page: params[:page], conditions: ["question ILIKE ?", "%#{params[:search]}%"])
      else
        @tasks = Task.paginate(page: params[:page], conditions: ["is_reviewed = ?", false])
      end
      render "tasks"
    else
      @task = Task.find(params[:id])
      @task.update_attribute(:is_reviewed, true)
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
