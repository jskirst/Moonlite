class GroupsController < ApplicationController
  include NewsfeedHelper
  before_filter :authenticate, except: [:new, :create, :show, :newsfeed, :join]
  before_filter :load_resource, except: [:new, :create]
  before_filter :authorize_resource, only: [:edit, :update, :dashboard, :account, :invite]
  
  def new
    @new_group = Group.new
    @new_group.plan_type = params[:p]
    render "groups/signup/form"
  end
  
  def create
    @show_nav_bar = false
    @show_footer = false
    @hide_background = false
    token = params[:group].delete(:token)
    if token.blank?
      plan_type = params[:group].delete(:plan_type)
      @new_group = Group.new(params[:group])
      @new_group.plan_type = plan_type
      if @new_group.save
        @creator = @new_group.creator
        @creator.reload
        sign_in(@creator)
        render json: { token: @new_group.token }
      else
        @errors = @new_group.errors.full_messages.join(". ") + @new_group.creator.errors.full_messages.join(". ")
        render json: { error: @errors }
      end
    else
      @new_group = Group.find_by_token(token)
      if @new_group.admin?(current_user)
        @new_group.coupon = params[:group][:coupon]
        if @new_group.save_with_stripe(params[:group][:stripe_token])
          redirect_to confirmation_group_url(@new_group)
        else
          @errors = @new_group.errors.full_messages.join(". ")
          render "groups/signup/form"
        end
      else
        raise "Access Denied: Not your group"
      end
    end
  end
  
  def confirmation
    @title = "Order Confirmation"
    @show_footer = true
    @hide_background = true
    @show_nav_bar = true
    render "groups/signup/confirmation"
  end
  
  def show
    if @group.is_private?
      redirect_to account_group_url(@group) and return
    end
    
    @title = "#{@group.name} Group"
    @users = @group.users.order "earned_points desc"
    @membership = @group.membership(current_user)
    @url_for_newsfeed = newsfeed_group_path(@group, order: params[:order])
    @suggested_paths = Path.suggested_paths(current_user)
    set_return_back_to(root_url) unless current_user
    render "show"
  end
  
  def newsfeed    
    feed = Feed.new(params, current_user)
    feed.url = newsfeed_group_path(@group.id, order: params[:order])
    feed.page = params[:page].to_i
    offset = params[:page].to_i * 15
    feed.posts = CompletedTask.joins(:submitted_answer, :user, :task => { :section => :path })
      .joins("INNER JOIN group_users on group_users.user_id = completed_tasks.user_id")
      .select(newsfeed_fields)
      .where("submitted_answers.locked_at is ?", nil)
      .where("submitted_answers.reviewed_at is not ?", nil)
      .where("group_users.group_id = ?", @group.id)
      .where("completed_tasks.status_id = ?", Answer::CORRECT)
    if params[:order] == "newest"
      feed.posts = feed.posts.order("created_at DESC")
    elsif params[:order] == "top"
      #raise "top"
      feed.posts = feed.posts.order("points_awarded DESC")
    else
      feed.posts = feed.posts.select("((submitted_answers.total_votes + 1) - ((current_date - DATE(completed_tasks.created_at))^2) * .1) as hotness").order("hotness DESC")
    end
    feed.posts = feed.posts.offset(offset).limit(15).eager_load
    
    render partial: "newsfeed/feed", locals: { feed: feed }
  end
  
  def edit    
  end
  
  def update
    @group.update_attributes(params[:group])
    if params[:group][:plan_type]
      flash[:success] = "Plan type has been updated."
    end
    
    if params[:redirect_uri]
      redirect_to params[:redirect_uri]
    else
      redirect_to @group
    end
  end
  
  def dashboard
    completed_tasks = CompletedTask.joins("INNER JOIN group_users on group_users.user_id = completed_tasks.user_id").where("group_users.group_id = ?", @group.id)
    @stats = {
      users:              @group.users,
      visits:             GroupUser.where("group_users.group_id = ? and group_users.created_at > ?", @group, 7.days.ago),
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
  
  def account
    @users = @group.users.where("group_users.hidden = ?", false)
    if params[:q]
      @users = @users.where("name ILIKE ? or email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
      if request.xhr?
        render partial: "account_table"
      end
    end
  end
  
  def style
    @group_custom_style = @group.custom_style
    unless @group_custom_style
      @group_custom_style = CustomStyle.new
      @group_custom_style.owner_id = @group.id
      @group_custom_style.owner_type = "Group"
      @group_custom_style.save!
    end
    
    unless request.get?
      @group_custom_style.update_attributes(params[:custom_style])
      flash[:success] = "Your styles have been saved."
    end
  end
  
  def invite
    GroupMailer.invite(params[:email], @group, join_group_url(@group, token: @group.token)).deliver
    flash[:success] = "Invite sent to #{params[:email]}"
    redirect_to account_group_url(@group)
  end
  
  def join
    create_or_sign_in unless current_user
    unless @group.group_users.find_by_user_id(current_user)
      group_user = @group.group_users.new
      group_user.user_id = current_user.id
      group_user.is_admin = true if params[:token] and @group.token == params[:token]
      group_user.save!
    end
    set_return_back_to(join_group_url(@group))
    render "pages/portal"
  end
  
  def leave
    @group.group_users.find_by_user_id(current_user.id).delete
    redirect_to @group
  end
  
  def sandbox
    @email = params[:email] || current_user.email
  end
  
  def paths
    @paths = @group.paths
  end
  
  def close
    if request.get?
      if @group.closed_at
        sign_out
        @show_nav_bar = false
        render "close_confirmation"
      end
    else
      @group.closed_at = Time.now
      @group.closed_reason = params[:group][:closed_reason]
      @group.save
      @show_nav_bar = false
      render "close_confirmation"
    end
  end
  
  private
  def load_resource
    @group = Group.find_by_permalink(params[:permalink]) if params[:permalink]
    @group = Group.find_by_permalink(params[:id]) if params[:id] && @group.nil?
    @group = Group.find_by_id(params[:id]) if params[:id] && @group.nil?
    @group_custom_style = @group.custom_style if @group
    @admin_group = @group
    redirect_to root_path unless @group
  end
  
  def authorize_resource
    unless @group.admin?(current_user) and @group.closed_at.nil?
      raise "Access Denied"
    end
  end
end