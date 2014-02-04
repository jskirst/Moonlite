class PathsController < ApplicationController
  include EventsHelper
  include NewsfeedHelper
  include HamsterPowered::HamsterHelper
  
  before_filter :authenticate, except: [:show, :newsfeed, :drilldown, :marketing]
  before_filter :load_resource, except: [:index, :new, :create, :drilldown, :marketing, :start]
  before_filter :load_group
  before_filter :authorize_edit, only: [:edit, :update, :destroy, :collaborator, :collaborators, :style, :upload]
  before_filter :authorize_view, only: [:continue, :show, :newsfeed]
  
  def index
    @hide_background = true
    if @group
      @paths = @group.paths.to_a
      @public_paths = Path.where.not(professional_at: nil)
      if params[:q]
        @public_paths = @public_paths.where("name ILIKE ?", "%#{params[:q]}%") unless params[:q].blank?
        if request.xhr?
          render partial: "paths/mb_challenges"
          return
        end
      end
      @public_paths = @public_paths.sort_by{|path| [path.name.upcase]}
      @new_custom_path = @group.paths.new
      render "groups/challenges"
    else
      @paths = current_user.paths.to_a + current_user.collaborating_paths.order("updated_at DESC").to_a
    end
  end
  
# Begin Path Creation
  
  def new
    @hide_background = true
    @path = Path.new
    @exact_path = nil
    @similar_paths = []
    if @group
      render "new_group"
    end
  end
  
  def start
    @hide_background = true
    @path = Path.new
    name = params[:path][:name]
    @exact_path = Path.where(group_id: nil).where(name: name).first
    unless params[:skip]
      @similar_paths = Path.where("name ILIKE ?", "%#{name}%").where(group_id: nil)
    end
    if @exact_path or not @similar_paths.empty?
      render "new"
    else
      @path.name = name
      render "start"
    end
  end
    

  def create
    @path = current_user.paths.new(params[:path])
    @path.user_id = current_user.id
    if @group
      @path.group_id = @group.id
      now = Time.now
      @path.published_at = now
      @path.public_at = now
      @path.approved_at = now
    end
    
    if @path.save
      unless params[:stored_resource_id].blank?
        assign_resource(@path, params[:stored_resource_id])
      end
      
      if @path.template_type == "subtopic"
        @path.sections.create!(name: "Topic 1")
        @path.sections.create!(name: "Topic 2")
        @path.sections.create!(name: "Topic 3")
        @path.sections.create!(name: "Topic 4")
      elsif @path.template_type == "difficulty"
        @path.sections.create!(name: "Novice")
        @path.sections.create!(name: "Intermediate")
        @path.sections.create!(name: "Advanced")
        @path.sections.create!(name: "Expert")
      else
        @path.sections.create!(name: @path.name)
      end
      
      if @path.group_id
        redirect_to edit_group_path_path(@path.group_id, @path.permalink)
      else
        redirect_to edit_path_path(@path.permalink)
      end
    else
      render 'new'
    end
  end
  
  def join
    if current_user.earned_points > 800
      @path.collaborations.create!(user_id: current_user.id, granting_user_id: @path.user_id)
      redirect_to edit_path_path(@path.permalink)
    end
  end

# Begin Path Editing  
  
  def edit
    @hide_background = true
    if @path.sections.empty?
      redirect_to new_section_path(:path_id => @path.id) and return
    end
    @topics = @path.topics
    @sections = @path.sections.order("id ASC")
  end
  
  def update
    @path.name = params[:path][:name] if params[:path][:name]
    @path.description = params[:path][:description] if params[:path][:name]
    @path.template = params[:path][:template] if params[:path][:template]
    @path.input_type = params[:path][:input_type] if params[:path][:input_type]

    if @enable_administration
      unless params[:path][:persona].blank?
        @path.path_personas.destroy_all
        @path.path_personas.create!(persona_id: params[:path][:persona])
      end
      if params[:path][:promoted].present?
        @path.promoted_at = params[:path][:promoted].to_i == 1 ? Time.now : nil
        @path.approved_at = params[:path][:approved].to_i == 1 ? Time.now : nil
        @path.professional_at = params[:path][:professional].to_i == 1 ? Time.now : nil
      end
    end
    
    unless params[:stored_resource_id].blank?
      @path.stored_resource.destroy if @path.stored_resource
      sr = StoredResource.find(params[:stored_resource_id])
      raise "FATAL: STEALING RESOURCE" if sr.owner_id
      sr.owner_id = @path.id
      sr.owner_type = @path.class.to_s
      sr.save
      @path.image_url = sr.obj.url
      @path.save
    end
    
    @path.save
    
    if params[:path][:approved] and @enable_administration
      redirect_to admin_paths_path
    else
      redirect_to edit_path_path(@path.permalink)
    end
  end
  
  def style
    @path_custom_style = @path.custom_style
    unless @path_custom_style
      @path_custom_style = CustomStyle.new
      @path_custom_style.owner_id = @path.id
      @path_custom_style.owner_type = "Path"
      @path_custom_style.save!
    end
    
    unless request.get?
      @path_custom_style.update_attributes(params[:custom_style])
      flash[:success] = "Your styles have been saved."
    end
  end
  
  def publish
    now = Time.now
    @path.sections.each { |s| s.update_attribute(:published_at, now) }
    @path.published_at = now
    @path.public_at = now
    if @path.group_id
      @path.approved_at = now
    end
    
    if @path.save
      flash[:success] = "#{@path.name} has been submitted. Once approved by an administrator, it will be accessible by the MetaBright community."
    else
      flash[:error] = "There was an error publishing."
    end
    redirect_to edit_path_path(@path.permalink)
  end
  
  def unpublish
    @path.published_at = nil
    if @path.save
      flash[:success] = "#{name_for_paths} has been unpublished and is no longer visible."
    else
      flash[:error] = "Oops, could not unpublish this #{name_for_paths}. Please try again."
    end
    redirect_to edit_path_path(@path.permalink)
  end

  def destroy
    if @path.group_id?
      @path.destroy
      flash[:success] = "#{name_for_paths} successfully deleted."
      redirect_to group_paths_path(@group)
    else
      @path.destroy
      flash[:success] = "#{name_for_paths} successfully deleted."
      redirect_to paths_path
    end
  end

  def collaborator
    if request.get?
      @collaborators = @path.collaborating_users
      @collaborator = @path.collaborations.new
    else
      if params[:collaborator].nil? || !(@user = User.find_by_email(params[:collaborator][:email]))
        flash[:error] = "MetaBright user does not exist."
      else 
        @collaboration = @path.collaborations.new(user_id: @user.id, granting_user_id: current_user.id)
        if @collaboration.save
          flash.now[:success] = "#{@user.name} successfully added as a collaborator."
        else
          flash.now[:error] = @collaborator.errors.full_messages.join(". ")
        end
      end
      redirect_to collaborator_path_path(@path.permalink)
    end
  end

  def undo_collaboration
    @collaboration = @path.collaborations.find_by_user_id(params[:user_id])
    if @collaboration.destroy
      flash[:alert] = "User will no longer have access."
    else
      flash[:error] = @collaboration.errors.full_messages.join(". ")
    end
    redirect_to collaborator_path_path(@path.permalink)
  end
  
  def upload
    flash[:success] = "Contacts successfully uploaded."
    @header = nil
    @tasks = []
    file = params["path"]["batch_file"]
    
    # Header must contain:
    # question, answer_new_1, answer_new_2, answer_new_3, answer_new_4, quoted_text, template, image_url, resource, resource_title, topic, difficulty
    path_id = @path.id
    section_id = @path.sections.last.id
    CSV.foreach(file.path) do |row|
      if @header
        task_hash = Hash[@header.zip(row)]
        task_hash["template"] = task_hash["image_url"]
        task_hash["answer_content"] = gather_answers(task_hash)
        task_hash["difficulty"] = Task::DIFFICULTY_TYPES.invert[task_hash["difficulty"]] || Task::EASY
        task_hash["path_id"] = path_id
        task_hash["section_id"] = section_id
        @tasks << Task.new(task_hash)
      else
        @header = row
      end
    end
    
    @tasks.each do |t|
      t.creator = current_user
      t.answer_type = t.answer_content.size == 0 ? Task::CREATIVE : Task::MULTIPLE
      t.answer_sub_type = Task::TEXT
    end
    
    #redirect_to edit_path_path(@path)
    render as_processing_screen(@tasks, :save!, edit_path_path(@path))
  end

# Begin Path Journey
  
  def continue
    current_user.enroll!(@path) unless current_user.enrolled?(@path)
    
    section = @path.next_section_for_user(current_user)
    
    if section.nil? || section.published_at.nil?
      redirect_to challenge_path(@path.permalink, c:true)
    else
      redirect_to start_section_path(section)
    end
  end
  
  def show
    if (@path.public_at.nil? and (current_user.nil? || @path.user != current_user)) or @path.group_id
      redirect_to root_path and return
    end
    
    if params[:submission]        
      @feed = Feed.new(page: params[:page], action: params[:action], user: current_user,)
      @feed.context = :submission
      @feed.submissions = CompletedTask.joins(:submitted_answer, :user, :task => :path)
        .select(newsfeed_fields)
        .where("users.locked_at is ? and users.private_at is ?", nil, nil)
        .where("submitted_answers.id = ?", params[:submission])
        .where("completed_tasks.status_id = ?", Answer::CORRECT)
        .where("submitted_answers.locked_at is ?", nil)
      
      if @feed.submissions.empty?
        flash[:error] = "This user's account has been marked as private. Their posts cannot be publicly viewed."
        redirect_to root_url and return
      end

      @title = @feed.submissions.first.try{ |p| p.question }
      render "submission" and return
    end
    
    @title = "#{@path.name} Skill Test" 
    @tasks = @path.tasks
    @responses = []
    
    if current_user
      clear_return_back_to
      session[:ssf] = 0
      @enrollment = current_user.enrolled?(@path) || current_user.enrollments.create(path_id: @path.id)
      if current_user.enrollments.size == 1 and @enrollment.total_points == 0
        redirect_to continue_path_path(@path.permalink) and return
      end
      @current_section = current_user.most_recent_section_for_path(@path)
      @tasks = Task.joins("LEFT OUTER JOIN completed_tasks on tasks.id = completed_tasks.task_id and completed_tasks.user_id = #{current_user.id}")
        .select("section_id, status_id, question, tasks.id, points_awarded, answer_type, answer_sub_type, completed_tasks.submitted_answer_id")
        .where("tasks.section_id = ? and tasks.locked_at is ? and tasks.archived_at is ? and tasks.reviewed_at is not ?", @current_section.id, nil, nil, nil)

      @core_tasks = @tasks.select { |t| t.core? }
      @challenge_tasks = @tasks.select { |t| t.creative? }
      @achievement_tasks = @tasks.select { |t| t.task? }
      
      @completed = params[:c]
      if @completed
        last_session = current_user.completed_tasks.last.try(:session_id)
        if last_session
          last_session_points = current_user.completed_tasks.where(session_id: last_session).to_a.inject(0){ |sum, ct| sum += ct.points_awarded.to_i }
          @points_gained = last_session_points
          @achievements = check_achievements(@points_gained.to_i, @enrollment, current_user)
        end
      end
      @achievements ||= {}
    else
      @display_sign_in = true
      set_return_back_to = challenge_url(@path.permalink)
    end
    
    @similar_paths = @path.similar_paths.where("name != ?", @path.name)
    social_tags(@path.name, @path.picture, @path.description)
    @display_launchpad = @completed
    @display_type = params[:type] || 2
      
    @leaderboard = User.joins(:enrollments)
      .select("users.id, enrollments.path_id, enrollments.total_points, users.name, users.username, users.locked_at, users.private_at, users.image_url")
      .where("users.private_at is ? and users.locked_at is ? ", nil, nil)
      .where("enrollments.path_id = ? and total_points > ?", @path.id, 0)
      .order("enrollments.total_points DESC")
      .limit(200)
      .to_a
      
    @enrollments = @leaderboard.shuffle.select{ |l| !l.image_url.blank? }.first(8)
    
    @url_for_newsfeed = generate_newsfeed_url
    if @enrollment and @enrollment.contribution_unlocked?
      @require_ace_editor = true
    end
    render "show"
  end
  
  def drilldown
    if params[:submission_id]
      submission = SubmittedAnswer.find(params[:submission_id])
      redirect_to submission_details_path(submission.path.permalink, submission.id)
    else
      task = Task.find(params[:task_id])
      redirect_to task_details_path(task.path.permalink, task.id)
    end
  end
  
  def newsfeed
    feed = Feed.new(page: params[:page], 
      action: params[:action], 
      user: current_user,
      url: newsfeed_path_path(@path.permalink, order: params[:order]),
      path_ids: [@path.id])

    offset = feed.page * 15
    feed.submissions = CompletedTask.joins(:submitted_answer, :user, :task => :path)
      .select(newsfeed_fields)
      .where("users.locked_at is ? and users.private_at is ?", nil, nil)
      .where("completed_tasks.status_id = ?", Answer::CORRECT)
      .where("tasks.archived_at is ?", nil)
      .where("submitted_answers.locked_at is ?", nil)
      .where("submitted_answers.reviewed_at is not ?", nil)
      .where("paths.id = ?", @path.id)
      
    if params[:submission]
      feed.submissions = feed.submissions.where("submitted_answers.id = ?", params[:submission])
    else
      if params[:task]
        feed.submissions = feed.submissions.where("completed_tasks.task_id = ?", params[:task]).order("total_votes DESC")
      elsif params[:order] == "newest"
        feed.submissions = feed.submissions.order("submitted_answers.id DESC")
      elsif params[:order] == "halloffame"
        feed.submissions = feed.submissions.where("submitted_answers.promoted_at is not ?", nil).order("submitted_answers.id DESC")
      elsif params[:order] == "following"
        user_ids = current_user.subscriptions.collect(&:followed_id)
        feed.submissions = feed.submissions.where("users.id in (?)", user_ids).order("completed_tasks.id DESC")
      # This elsif displays the newsfeed HoF view if the user isnt signed in and there are at least 3 HoF answers
      elsif not current_user and feed.submissions.where("submitted_answers.promoted_at is not ?", nil).count >= 3
        feed.submissions = feed.submissions.where("submitted_answers.promoted_at is not ?", nil).order("submitted_answers.id DESC")
      else
        feed.submissions = feed.submissions.select("((submitted_answers.total_votes + 1) - ((current_date - DATE(completed_tasks.created_at))^2) * .1) as hotness").order("hotness DESC")
      end
    end
    feed.submissions = feed.submissions.offset(offset).limit(15)
    
    render partial: "newsfeed/feed", locals: { feed: feed }
  end
  
  def leaderboard
    tasks               = @path.completed_tasks.joins(:task).select("completed_tasks.*, tasks.answer_type").where("tasks.answer_type = ?", Task::MULTIPLE)
    total_tasks         = tasks.count
    total_correct       = tasks.where(status_id: Answer::CORRECT).count
    total_incorrect     = tasks.where(status_id: Answer::INCORRECT).count
    average_score       = tasks.where(status_id: Answer::CORRECT).average(:points_awarded).to_f.round(4)
    crs                 = @path.completed_tasks.joins(:task, :submitted_answer).where("tasks.answer_type = ? and status_id = ?", Task::CREATIVE, Answer::CORRECT)
    total_crs           = crs.count
    total_votes         = crs.sum(:total_votes)
    total_drafts        = @path.completed_tasks.joins(:task).where("tasks.answer_type = ? and status_id = ?", Task::CREATIVE, Answer::INCOMPLETE).count
    @overall_statistics = [total_tasks, total_correct, total_incorrect, average_score, total_crs, total_votes, total_drafts].join(",")
    
    @statistics         = @path.enrollments.limit(500).order("total_points DESC").collect do |e|
      completed_tasks   = e.completed_tasks.joins(:task).select("completed_tasks.*, tasks.answer_type").where("answer_type = ?", Task::MULTIPLE)
      total_tasks       = completed_tasks.count
      total_correct     = completed_tasks.where(status_id: Answer::CORRECT).count
      total_incorrect   = completed_tasks.where(status_id: Answer::INCORRECT).count
      average_points    = completed_tasks.where(status_id: Answer::CORRECT).average(:points_awarded).to_f.round(4)
      
      completed_tasks   = e.completed_tasks.joins(:task, :submitted_answer).select("completed_tasks.*, tasks.answer_type, submitted_answers.total_votes").where("answer_type = ?", Task::CREATIVE)
      total_crs         = completed_tasks.where(status_id: Answer::CORRECT).count
      total_votes       = completed_tasks.sum(:total_votes)
      total_drafts      = completed_tasks.where(status_id: Answer::INCOMPLETE).count
      [e.rank, e.total_points, e.metascore, e.metapercentile, total_tasks, total_correct, total_incorrect, average_points, total_crs, total_votes, total_drafts].join(",")
    end
    render "leaderboard", layout: false
  end

  private    
    def load_resource
      @path = Path.cached_find(params[:permalink] || params[:id])
      unless @path
        @path = Path.find_by_permalink(params[:permalink]) if params[:permalink]
        @path = Path.find_by_permalink(params[:id]) if params[:id] && @path.nil?
        @path = Path.find_by_id(params[:id]) if params[:id] && @path.nil?
      end
      @path_custom_style = @path.custom_style if @path
      
      unless @path
        flash[:error] = "We're sorry, we could not find a challenge by that name!"
        redirect_to root_path 
      end
    end
    
    def load_group
      if params[:group_id]
        @group = current_user.groups.where(permalink: params[:group_id]).first
        @group = current_user.groups.where(id: params[:group_id]).first unless @group
        raise "Access Denied: Not a group member." unless @group
      elsif @path and @path.group_id
        @group = current_user.groups.where(id: @path.group_id).first
        raise "Access Denied: Not a group member." unless @group
      end
      
      if @group
        @hide_background = true
        @group_custom_style = @group.custom_style 
      end
      
      if @group and not @group.admin?(current_user)
        raise "Access Denied"
      end
    end
    
    def authorize_edit
      raise "Edit Access Denied" unless @path.nil? || can_edit_path(@path) || @enable_administration
    end
    
    def authorize_view
      raise "View Access Denied" unless (@path.published_at && @path.approved_at && @path.published_at) || can_edit_path(@path)
    end
    
    def generate_newsfeed_url
      if params[:submission]
        return newsfeed_path_path(@path.permalink, submission: params[:submission])
      elsif params[:task]
        return newsfeed_path_path(@path.permalink, task: params[:task], page: params[:page])
      elsif params[:order]
        return newsfeed_path_path(@path.permalink, order: params[:order], page: params[:page])
      else
        return newsfeed_path_path(@path.permalink)
      end
    end
end