class CompaniesController < ApplicationController
  before_filter :authenticate
  before_filter { raise "ACCESS DENIED" unless @enable_administration }
  
  def overview
    excluded = [0]
    unless params[:excluded]
      excluded = User.joins(:user_role).where("user_roles.enable_administration = ? or is_fake_user = ? or is_test_user = ? or locked_at is not ?", true, true, true, nil).to_a.collect &:id
    end

    @users                  = User.where("created_at >= '01-27-2013'").where("id not in (?)", excluded).count
    @returning_users        = User.where("created_at >= '01-27-2013'").where("id not in (?)", excluded).where("created_at != login_at").count
    @arena_answers          = CompletedTask.where("completed_tasks.created_at >= '01-27-2013'").joins(:task).where("user_id not in (?)", excluded).where("tasks.answer_type = ?", Task::MULTIPLE).count
    @creative_answers       = CompletedTask.where("completed_tasks.created_at >= '01-27-2013'").joins(:task).where("user_id not in (?)", excluded).where("tasks.answer_type = ?", Task::CREATIVE).count
    @task_answers           = CompletedTask.where("completed_tasks.created_at >= '01-27-2013'").joins(:task).where("user_id not in (?)", excluded).where("tasks.answer_type = ?", Task::CHECKIN).count
    @arena_questions        = Task.where("tasks.created_at >= '01-27-2013'").where("creator_id not in (?)", excluded).where("tasks.answer_type = ?", Task::MULTIPLE).count
    @creative_questions     = Task.where("tasks.created_at >= '01-27-2013'").where("creator_id not in (?)", excluded).where("tasks.answer_type = ?", Task::CREATIVE).count
    @task_questions         = Task.where("tasks.created_at >= '01-27-2013'").where("creator_id not in (?)", excluded).where("tasks.answer_type = ?", Task::CHECKIN).count
    @votes                  = Vote.where("votes.created_at >= '01-27-2013'").where("user_id not in (?)", excluded).count
    @comments               = Comment.where("comments.created_at >= '01-27-2013'").where("user_id not in (?)", excluded).count
    @issues                 = TaskIssue.where("task_issues.created_at >= '01-27-2013'").where("user_id not in (?)", excluded).count
    
    time_limit              = 24.hours.ago
    @new_users              = User.where("id not in (?)", excluded).where("created_at >= ?", time_limit).count
    @new_returning_users    = User.where("id not in (?)", excluded).where("created_at <= ? and login_at >= ?", time_limit, time_limit).count
    @new_arena_answers      = CompletedTask.joins(:task).where("user_id not in (?)", excluded).where("tasks.answer_type = ?", Task::MULTIPLE).where("completed_tasks.created_at >= ?", time_limit).count
    @new_creative_answers   = CompletedTask.joins(:task).where("user_id not in (?)", excluded).where("tasks.answer_type = ?", Task::CREATIVE).where("completed_tasks.created_at >= ?", time_limit).count
    @new_task_answers       = CompletedTask.joins(:task).where("user_id not in (?)", excluded).where("tasks.answer_type = ?", Task::CHECKIN).where("completed_tasks.created_at >= ?", time_limit).count
    @new_arena_questions    = Task.where("creator_id not in (?)", excluded).where("tasks.answer_type = ?", Task::MULTIPLE).where("created_at >= ?", time_limit).count
    @new_creative_questions = Task.where("creator_id not in (?)", excluded).where("tasks.answer_type = ?", Task::CREATIVE).where("created_at >= ?", time_limit).count
    @new_task_questions     = Task.where("creator_id not in (?)", excluded).where("tasks.answer_type = ?", Task::CHECKIN).where("created_at >= ?", time_limit).count
    @new_votes              = Vote.where("user_id not in (?)", excluded).where("created_at >= ?", time_limit).count
    @new_comments           = Comment.where("user_id not in (?)", excluded).where("created_at >= ?", time_limit).count
    @new_issues             = TaskIssue.where("user_id not in (?)", excluded).where("created_at >= ?", time_limit).count
  end
  
  def users
    if request.get?
      conditions = params[:search].nil? ? nil : ["name ILIKE ? or email ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%"]
      @sort = params[:sort] || "id"
      @users = User.paginate(page: params[:page], conditions: conditions, order: "#{@sort} DESC").includes(:user_role)
    else
      user = User.find(params[:id])
      toggle(:locked_at, user)
      render json: { status: status }
    end
  end
  
  def paths
    conditions = params[:search].nil? ? nil : ["name ILIKE ?", "%#{params[:search]}%"]
    @paths = current_company.all_paths.paginate(page: params[:page], conditions: conditions)
  end
  
  def path
    @path = Path.find(params[:id])
  end
  
  def submissions
    if request.get?
      conditions = params[:search].nil? ? ["reviewed_at is ?", nil] : ["content ILIKE ?", "%#{params[:search]}%"]
      @submissions = SubmittedAnswer.paginate(page: params[:page], conditions: conditions)
    else
      submission = SubmittedAnswer.find(params[:id])
      toggle(:reviewed_at, submission)
      render json: { status: "success" }
    end
  end
  
  def tasks
    if request.get?
      conditions = params[:search].nil? ? ["reviewed_at is ?", nil] : ["question ILIKE ?", "%#{params[:search]}%"]
      @tasks = Task.paginate(page: params[:page], conditions: conditions)
    else
      task = Task.find(params[:id])
      toggle(:reviewed_at, task)
      render json: { status: "success" }
    end
  end
  
  def comments
    if request.get?
      conditions = params[:search].nil? ? ["reviewed_at is ?", nil] : ["content ILIKE ?", "%#{params[:search]}%"]
      @comments = Comment.paginate(page: params[:page], conditions: conditions)
    else
      comment = Comment.find(params[:id])
      toggle(:reviewed_at, comment)
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
  
  private
  
  def toggle(attr, obj)
    obj.update_attribute(attr, obj.read_attribute(attr).nil? ? Time.now : nil)
  end
    
end