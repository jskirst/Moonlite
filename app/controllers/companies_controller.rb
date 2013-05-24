class CompaniesController < ApplicationController
  before_filter :authenticate
  before_filter { raise "ACCESS DENIED" unless @enable_administration }
  
  def overview
    @excluded = User.joins(:user_role).where("user_roles.enable_administration = ? or is_fake_user = ? or is_test_user = ? or locked_at is not ? and earned_points > 0", true, true, true, nil).to_a.collect &:id

    @stats = {
      users:              User.where("id not in (?) and earned_points > ?", @excluded, 300),
      registrations:      User.where("id not in (?) and email not like ? and earned_points > ?", @excluded, '%@metabright.com', 300),
      arena_answers:      filter(CompletedTask.joins(:task).where("tasks.answer_type = ?", Task::MULTIPLE).where("status_id >= ?",0)),
      creative_answers:   filter(CompletedTask.joins(:task).where("tasks.answer_type = ?", Task::CREATIVE).where("status_id >= ?",0)),
      task_answers:       filter(CompletedTask.joins(:task).where("tasks.answer_type = ?", Task::CHECKIN).where("status_id >= ?",0)),
      arena_questions:    filter(Task.where("tasks.answer_type = ?", Task::MULTIPLE), :creator),
      creative_questions: filter(Task.where("tasks.answer_type = ?", Task::CREATIVE), :creator),
      task_questions:     filter(Task.where("tasks.answer_type = ?", Task::CHECKIN), :creator),
      votes:              filter(Vote),
      comments:           filter(Comment),
      issues:             filter(TaskIssue)
    }
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
  
  def user
    @user = User.find(params[:id])
    @visits = @user.visits.order("id ASC")
    if not @visits.empty? and not @visits.first.visitor_id.nil?
      presignup_visits = Visit.where("visitor_id = ? and user_id is ?", @visits.first.visitor_id, nil)
      @visits = presignup_visits + @visits
    end
  end
  
  def paths
    conditions = params[:search].nil? ? nil : ["name ILIKE ?", "%#{params[:search]}%"]
    @paths = current_company.all_paths.paginate(page: params[:page], conditions: conditions).order("id DESC")
  end
  
  def path
    @path = Path.find(params[:id])
  end
  
  def submissions
    if request.get?
      if params[:search]
        @submissions = SubmittedAnswer.paginate(page: params[:page], conditions: ["content ILIKE ?", "%#{params[:search]}%"])
      else
        @submissions = SubmittedAnswer.paginate(page: params[:page], joins: [:completed_task], conditions: ["reviewed_at is ? and locked_at is ? and completed_tasks.status_id = ?", nil, nil, Answer::CORRECT])
      end
    else
      submission = SubmittedAnswer.find(params[:id])
      if params[:mark] == "locked"
        toggle(:locked_at, submission)
      elsif params[:mark] == "promoted"
        toggle(:promoted_at, submission)
      else
        toggle(:reviewed_at, submission)
      end
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
      if params[:mark] == "locked"
        toggle(:reviewed_at, comment)
        toggle(:locked_at, comment)
      else
        toggle(:reviewed_at, comment)
      end
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
  
  def funnel
    @number_of_days = (params[:days] || 7).to_i
    time = @number_of_days.days.ago
    #@total_visits = Visit.select("DISTINCT visitor_id").where("created_at > ?", time).where("user_id is ?", nil).count
    all_new = User.where("created_at > ?", time)
    @total_new = all_new.count
    all_engaged = all_new.where("earned_points >= 300")
    @total_engaged = all_engaged.count
    all_seen_opportunities = all_engaged.where(seen_opportunities: true)
    @total_seen_opportunities = all_seen_opportunities.count
    @total_unregistered = all_seen_opportunities.where("email like ?", '%@metabright.com%').count
    all_registered = all_seen_opportunities.where("email not like ?", '%@metabright.com%')
    @total_registered_professional = all_registered.where("wants_full_time = ? or wants_part_time = ? or wants_internship = ?", true, true, true).count
    @total_registered_unprofressional = all_registered.where("wants_full_time is ? and wants_part_time is ? and wants_internship is ?", nil, nil, nil).count
  end
  
  private
  def toggle(attr, obj)
    obj.update_attribute(attr, obj.read_attribute(attr).nil? ? Time.now : nil)
  end
    
  def filter(query, user_table_name = :user)
    query.joins(user_table_name).where("users.id not in (?) and users.earned_points > ?", @excluded, 300)
  end
end