class AdminController < ApplicationController
  include AdminHelper
  include EnrollmentsHelper
  before_action :authenticate
  before_action { raise "ACCESS DENIED" unless @enable_administration }
  
  def overview
    @excluded = User.where("enable_administration = ? or is_fake_user = ? or is_test_user = ? or locked_at is not ? and earned_points > 0", true, true, true, nil).to_a.collect &:id

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
      @users = User.paginate(page: params[:page], conditions: conditions, order: "#{@sort} DESC")
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
    @paths = Path.where(group_id: nil)
    if params[:search].present?
      @paths = @paths.where("name ILIKE ?", "%#{params[:search]}%")
    end
    @paths = @paths.paginate(page: params[:page]).order("id DESC")
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
      if params[:deny]
        issue = current_user.task_issues.new(task_id: task.id, issue_type: params[:deny].to_i)
        issue.save!
      end
      task.update_attribute(:reviewed_at, Time.now())
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
  
  def funnel
    mode = params[:mode]
    if mode.blank? or mode == "funnel"
      domain = Rails.env == "development" ? "localhost:3000" : "www.metabright.com"
      @number_of_days = (params[:days] || 7).to_i
      time = @number_of_days.days.ago
      #@total_visits = Visit.select("DISTINCT visitor_id").where("created_at > ?", time).where("user_id is ?", nil).count
      all_new = User.where("users.created_at > ?", time)
      @total_new = all_new.count
      all_engaged = all_new.where("earned_points >= 300")
      @total_engaged = all_engaged.count
      all_seen_opportunities = all_engaged.where(seen_opportunities: true)
      @total_seen_opportunities = all_seen_opportunities.count
      @total_unregistered = all_seen_opportunities.where("email like ?", '%@metabright.com%').count
      all_registered = all_seen_opportunities.where("email not like ?", '%@metabright.com%')
      @total_registered_professional = all_registered.where("wants_full_time = ? or wants_part_time = ? or wants_internship = ?", true, true, true).count
      @total_registered_unprofressional = all_registered.where("wants_full_time is ? and wants_part_time is ? and wants_internship is ?", nil, nil, nil).count
    
      visits = all_new.select("users.name, users.id, users.earned_points, MAX(visits.id) as visit_id")
        .joins("LEFT JOIN visits on visits.user_id = users.id")
        .group("users.id")
        .order("users.id")
        .collect(&:visit_id)
      @total_visits = visits.size
      @null_last_visits = visits.count{ |v| v.nil? }
      visits = Visit.where("id in (?)", visits).pluck(:request_url).collect{ |v| v.gsub(/[0-9]{10}/,'').gsub(/[0-9]{2,3}/,'') }
      @last_visits_with_count = Hash.new(0)
      visits.each{|y| @last_visits_with_count[y] += 1 }
      @last_visits_with_count = @last_visits_with_count.sort_by{ |k,v| v }.reverse.first(100)
      render "admin/funnel/funnel"
    elsif mode == "signups"
      #.select("users.earned_points, users.email, date_part('days', now() - users.created_at) as created")
      days = (params[:days] || 120).to_i
      if params[:week]
        date_select = "users.earned_points, users.email, date_part('weeks', users.created_at) as created"
      else
        date_select = "users.earned_points, users.email, DATE(users.created_at) as created"
      end
      @users = User.select(date_select)
        .where("users.created_at > ?", days.days.ago)
        .joins(:visits)
        .group("visits.user_id, users.earned_points, users.email, created")
        .having("count(visits.id) >= 2")
        .order("created DESC")
        .to_a
      @users.reverse!
      @signups = @users.chunk{ |u| u.created }.collect do |date, users| 
        [
          date, 
          users.length.to_i, 
          users.count{|u| !u.email.include?("@metabright.com")}.to_i,
          users.inject(0){|sum, u| sum += u.earned_points }.to_i
        ]
      end
      @signups_by_date = {}
      @signups.each do |s|
        @signups_by_date[s[0]] = {
          users: s[1], #total users
          guests: s[1] - s[2], #users that didn't signup
          registered: s[2], #users that signed up
          perc_registered: (s[2].to_f / s[1]) * 100, #percent signup
          total_points: s[3], #total points
          avg_points: (s[3].to_f / s[1]), #average total points / 1000
        }
      end
      @dates = @signups_by_date.keys
      render "admin/funnel/signups"
    end
    # profile_views_with_scores = all_new.select("DISTINCT on (users.id) ('http://#{domain}/' || lower(users.username)) as yeah, users.name, users.earned_points, users.id, visits.request_url ").joins("LEFT JOIN visits on visits.user_id = users.id and visits.request_url = ('http://#{domain}/' || lower(users.username))")
    # yes_profile_scores = []
    # no_profile_scores = []
    # profile_views_with_scores.each{ |v| v.request_url.blank? ? (no_profile_scores << v) : (yes_profile_scores << v) }
    # raise yes_profile_scores.to_yaml
  end
  
  def visits
    if params[:visitor]
      @visits = Visit.where("visitor_id = ?", params[:visitor])
    elsif params[:user]
      @visits = Visit.where("user_id = ?", params[:user])
    else
      conditions = params[:search].nil? ? nil : ["request_url = ?", params[:search]]
      @visits = Visit.where(conditions)
    end
    @visits = @visits.select("visits.*, users.username")
      .joins("LEFT JOIN users on visits.user_id=users.id")
      .order("visits.id DESC")
      .paginate(page: params[:page])
  end
  
  def visit
    @visit = Visit.find(params[:visit_id])
  end
  
  def groups
    conditions = params[:search].nil? ? [] : ["name ILIKE ?", "%#{params[:search]}%"]
    @groups = Group.paginate(page: params[:page], conditions: conditions)
  end
  
  def group
    @group = Group.find_by_id(params[:group_id])
  end
  
  def email
    if request.get?
      @email = Email.new
    else
      @email = Email.new(params[:email])
      GroupMailer.send_email(@email).deliver
      flash[:success] = "Email sent to #{@email.to_name} <#{@email.to_email}>."
    end
    @email.to_email = nil
    @email.to_name = nil
  end
  
  def grade
    @user = User.where(username: params[:username]).first
    @results = []
    @user.enrollments.each do |enrollment|
      @results << extract_enrollment_details(enrollment)
    end
    render "evaluations/grade"
  end
  
  private
  def toggle(attr, obj)
    obj.update_attribute(attr, obj.read_attribute(attr).nil? ? Time.now : nil)
  end
    
  def filter(query, user_table_name = :user)
    query.joins(user_table_name).where("users.id not in (?) and users.earned_points > ?", @excluded, 300)
  end
end