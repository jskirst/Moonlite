class PathsController < ApplicationController
  include OrderHelper
  include UploadHelper
  
	before_filter :authenticate, :except => [:hero]
	before_filter :company_admin, :except => [:hero, :index, :show, :continue, :marketplace, :review, :purchase]
	before_filter :get_path_from_id, :except => [:index, :new, :create, :marketplace]
	before_filter :unpublished_not_for_purchase, :only => [:review, :purchase]
	before_filter :unpublished_for_admins_only, :only => [:show, :continue]
  
  def show
		@title = @path.name
		#@info_resources = @path.info_resources(:limit => 5)
		@achievements = @path.achievements.all(:limit => 20)
    @enrolled_users = @path.enrolled_users.all(:limit => 20)
		@sections = @path.sections.find(:all, :conditions => ["sections.is_published = ?", true])
    @current_position = @path.current_section(current_user).position unless @sections.empty?
    @enrolled = current_user.enrolled?(@path)
    if current_user.path_started?(@path)
      @start_mode = @path.completed?(current_user) ? "View Score" : "Continue Path"
    elsif current_user.enrolled?(@path)
      @start_mode = "Get Started"
    else
      @start_mode = "Enroll"
    end
	end

# Begin Path Creation
	
	def new
		@path = Path.new
    @category_types = Path.category_types
		@title = "New Path"
	end

	def create
		params[:path][:company_id] = current_user.company.id
		@path = current_user.paths.build(params[:path])
		if @path.save
			flash[:success] = "Path created."
			redirect_to edit_path_path(@path, :m => "start")
		else
			@title = "New Path"
      @category_types = Path.category_types
			render 'new'
		end
	end

# Begin Path Editing  
  
	def edit
		@title = "Edit"
    @file_upload_possible = @path.sections.size == 0 ? true : false
    @mode = params[:m]
		if params[:m] == "settings"
			render "edit_settings"
		elsif params[:m] == "achievements"
			@achievements = @path.achievements
			render "edit_achievements"
		else
      @start_mode = true if @mode == "start"
      @mode = "sections"
    	@sections = @path.sections
      if params[:a] == "reorder"
        @reorder = true
      end
      render "edit_sections"
    end
	end
	
	def update
		if params[:path][:image_url].blank?
			params[:path].delete("image_url")
		end
    if params[:path][:is_published] == "1"
      if @path.sections.where(["is_published = ?", true]).count.zero?
        flash[:error] = "You need to publish at least one section before you can make your path publicly available."
        render 'edit' 
        return
      end
    end
		if @path.update_attributes(params[:path])
			flash[:success] = "Changes saved."
			redirect_to edit_path_path(@path)
		else
			@title = "Edit Path"
			render 'edit'
		end
	end
  
  def reorder_sections
    old_order = @path.sections.map { |s| [s.id, s.position] }
    new_order = params[:sections][:positions].map { |id, position| [id.to_i, position.to_i] }
    revised_order = reorder(old_order, new_order)
    revised_order.each do |s|
      @path.sections.find(s[0]).update_attribute(:position, s[1])
    end
    redirect_to edit_path_path(@path, :m => "sections")
  end
  
  def divide
  end

  def destroy
		@path.destroy
		flash[:success] = "Path successfully deleted."
		redirect_back_or_to root_path
	end

# Begin Path Journey
  
	def continue
		@section = current_user.most_recent_section_for_path(@path)
    until @section.nil? || !@section.completed?(current_user)
      @section = @path.next_section(@section)
    end
    if @section.nil? || @section.is_published == false
      @total_points_earned = @path.enrollments.where("enrollments.user_id = ?", current_user.id).first.total_points
      @similar_paths = @path.similar_paths
      @suggested_paths = @path.suggested_paths(current_user)
      render "completion"
    else
      redirect_to @section
    end
	end

  def hero
    @title = @path.name
    @user_hero = User.find_by_id(params[:hero])
    @hero_score = @user_hero.enrollments.where("path_id = ?", @path.id).first.total_points
    @other_completed_paths = @user_hero.enrollments.includes(:path).where("paths.id != ?", @path.id).all
    @info_resources = @path.info_resources(:limit => 5)
		@achievements = @path.achievements.all(:limit => 5)
    @sections = @path.sections.find(:all, :conditions => ["sections.is_published = ?", true])
  end
  
# Begin Path File Upload
	
	def file
		@title = "File"
	end
	
	def preview
    begin
      logger.debug 
      read_file(params[:path][:file])
      @collected_answers = params[:collected_answers]
      @tab_delimited = params[:tab_delimited]
      @path_description = get_path_description
      @sections = []
      details = get_section(@sections.size + 1)
      until details.nil? || !flash[:error].nil?
        s = @path.sections.build(details)
        if s.valid?
          tasks = get_section_tasks(@sections.size + 1)
          unless tasks.nil?
            valid_tasks = []
            tasks.each do |task|
              t = s.tasks.build(task)
              valid_tasks << t
              #There will alway be one error for section blank
              flash[:error] =  t.errors.full_messages.join(". ") if t.errors.count > 1
            end
            if flash[:error].nil?
              @sections << [s, valid_tasks]
              details = get_section(@sections.size + 1)
            end
          else
            flash[:error] = "There were no tasks found for section: " + s.name
            break
          end
        else
          flash[:error] = s.errors.full_messages.join(". ")
        end
      end
    rescue
     flash[:error] = "An error occurred while processing your file. Please check your file for any errors and try to upload it again."
     logger.debug $!.to_s
     redirect_to file_path_path(@path)
    end
	end
  
  def upload
    begin
      sections = params[:path][:sections]
      @path.update_attribute("description", params[:path][:description])
      sections.each do |id, s|
        section = @path.sections.create!(:name => s[:name], :instructions => s[:instructions])
        s[:tasks].each { |id, t| section.tasks.create!(t) }
      end
      redirect_to edit_path_path(@path)
    rescue Exception => e
      logger.debug e.to_s
      flash[:error] = "An error occurred while processing your file. Please check your file for any errors and try to upload it again."
      redirect_to file_path_path(@path)
    end
  end

# Begin Corporate Path Marketplace #
	
	def marketplace
		@title = "Marketplace"
		if !params[:search].nil?
			@query = params[:search]
			@paths = Path.find(:all, :conditions => ["is_purchaseable = ? and is_published = ? and name LIKE ?", true, true, "%#{@query}%"])
		end
	end
	
	def review
		@title = "Review purchase"
	end
	
	def purchase
		UserTransaction.create!({
			:user_id => current_user.id,
			:path_id => @path.id,
			:amount => 15.00,
			:status => 0})

		purchased_path = current_user.paths.create!({
			:user_id => current_user.id,
			:company_id => @current_user.company.id,
			:purchased_path_id => @path.id,
			:name => @path.name,
			:description => @path.description,
			:amount => 15.00,
			:status => 0})
		
		@path.sections.each do |s|
			purchased_section = purchased_path.sections.create!(
				:name => s.name,
				:instructions => s.instructions,
				:position => s.position
			)
			s.tasks.each do |t|				
				purchased_section.tasks.create!(
					:question => t.question,
					:answer1 => t.answer1,
					:answer2 => t.answer2,
					:answer3 => t.answer3,
					:answer4 => t.answer4,
					:correct_answer => t.correct_answer,
					:points => t.points,
					:resource => t.resource
				)
			end
		end
		@title = "Purchase successful"
		flash[:success] = "Purchase successful. Enjoy!."
	end
	
	private
		def get_path_from_id
			if !@path = Path.find_by_id(params[:id])
				flash[:error] = "No path found for the argument supplied."
				redirect_to root_path and return
			end
		end
		
		def unpublished_not_for_purchase
			if !(@path.is_published && @path.is_purchaseable)
				flash[:error] = "This path is not available for access."
				redirect_to root_path and return
			end
		end
		
		def unpublished_for_admins_only
			if !@path.is_published && !current_user.company_admin?
				flash[:error] = "You do not have access to this Path. Please contact your administrator to gain access."
				redirect_to root_path
			end
		end
end