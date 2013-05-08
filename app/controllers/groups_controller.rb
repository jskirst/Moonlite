class GroupsController < ApplicationController
  include NewsfeedHelper  
  
  before_filter :authenticate, except: [:show, :newsfeed]
  before_filter :load_resource
  before_filter :authorize_resource, only: [:edit, :update, :dashboard]
  
  def show    
    @title = "#{@group.name} Group"
    @users = @group.users.order "earned_points desc"
    @membership = @group.membership(current_user)
    @url_for_newsfeed = newsfeed_group_path(@group)
    @suggested_paths = Path.suggested_paths(current_user)
    session[:redirect_back_to] = root_url
    render "show"
  end
  
  def newsfeed
    offset = 0    
    feed = Feed.new(params, current_user)
    feed.url = newsfeed_group_path(@group.id, order: "hot")
    feed.page = 0
    feed.posts = CompletedTask.joins("INNER JOIN group_users on group_users.user_id = completed_tasks.user_id")
      .joins(:submitted_answer)
      .where("submitted_answers.locked_at is ?", nil)
      .where("submitted_answers.reviewed_at is not ?", nil)
      .where("group_users.group_id = ?", @group.id)
    feed.posts = feed.posts.order("total_votes DESC")
    feed.posts = feed.posts.where("completed_tasks.status_id = ?", Answer::CORRECT).offset(offset).limit(15)
    feed.posts = feed.posts.eager_load
    
    render partial: "newsfeed/feed", locals: { feed: feed }
  end
  
  def edit    
  end
  
  def update
    @group.update_attributes(params[:group])
    redirect_to @group
  end
  
  def dashboard
    completed_tasks = CompletedTask.joins("INNER JOIN group_users on group_users.user_id = completed_tasks.user_id").where("group_users.group_id = ?", @group.id)
    @stats = {
      users:              @group.users,
      visits:             Visit.joins("INNER JOIN group_users on group_users.user_id = visits.user_id").where("group_users.group_id = ?", @group_id),
      arena_answers:      completed_tasks.joins(:task).where("tasks.answer_type = ?", Task::MULTIPLE).where("status_id >= ?",0),
      creative_answers:   completed_tasks.joins(:task).where("tasks.answer_type = ?", Task::CREATIVE).where("status_id >= ?",0)
    }
    @paths = Path.joins(:path_personas).where("path_personas.persona_id = ?", 1)
    if params[:search]
      @users = @group.users.where("name ILIKE ? or email ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%").paginate(page: params[:page])
    elsif params[:p]
      @path = Path.find(params[:p])
      @users = @group.users.joins("INNER JOIN enrollments on users.id = enrollments.user_id").where("enrollments.path_id = ?", @path.id).paginate(page: params[:page], order: "enrollments.total_points desc")
    else 
      @users = @group.users.paginate(page: params[:page])
    end
  end
  
  def join
    @group.group_users.create! user: current_user
    redirect_to @group
  end
  
  def leave
    @group.group_users.find_by_user_id(current_user.id).delete
    redirect_to @group
  end
  
  
  private
  def load_resource
    @group = Group.find_by_permalink(params[:permalink]) if params[:permalink]
    @group = Group.find_by_permalink(params[:id]) if params[:id] && @group.nil?
    @group = Group.find_by_id(params[:id]) if params[:id] && @group.nil?
    redirect_to root_path unless @group
  end
  
  def authorize_resource
    unless @group.admin?(current_user)
      raise "Access Denied"
    end
  end
end