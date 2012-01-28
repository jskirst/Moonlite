require 'csv'
class PathsController < ApplicationController
	before_filter :authenticate
	before_filter :company_admin, :except => [:index, :show, :continue, :marketplace, :review, :purchase]
	before_filter :get_path_from_id, :except => [:index, :new, :create, :marketplace]
	before_filter :unpublished_not_for_purchase, :only => [:review, :purchase]
	before_filter :unpublished_for_admins_only, :only => [:show, :continue]
	
	def index
		@paths = Path.paginate(:page => params[:page], :conditions => ["paths.company_id = ? and paths.is_published = ?", current_user.company.id, true])
		@unpublished_paths = Path.paginate(:page => params[:page], :conditions => ["paths.company_id = ? and paths.is_published = ?", current_user.company.id, false])
		@title = "All Paths"
	end
	
	def new
		@path = Path.new
		@title = "New Path"
	end

	def create
		params[:path][:company_id] = current_user.company.id
		@path = current_user.paths.build(params[:path])
		if @path.save
			flash[:success] = "Path created."
			redirect_to @path
		else
			@title = "New Path"
			render 'new'
		end
	end
	
	def show
		@title = @path.name
		@info_resources = @path.info_resources(:limit => 5)
		@achievements = @path.achievements.all(:limit => 5)
		@sections = @path.sections
	end
	
	def edit
		@title = "Edit"
		if params[:m] == "settings"
			render "edit_settings"
		elsif params[:m] == "sections"
			@sections = @path.sections
			render "edit_sections"
		elsif params[:m] == "achievements"
			@achievements = @path.achievements
			render "edit_achievements"
		end
	end
	
	def update
		if params[:path][:image_url].blank?
			params[:path].delete("image_url")
		end
		if @path.update_attributes(params[:path])
			flash[:success] = "Changes saved."
			redirect_to @path
		else
			@title = "Edit Path"
			render 'edit'
		end
	end
	
	def continue
		@section = current_user.most_recent_section(@path)
		if @section.nil?
			redirect_to continue_section_path(@path.sections.first)
		else
			redirect_to continue_section_path(@section)
		end
	end
	
	def file
		@title = "File"
	end
	
	def upload
		uploaded_file = params[:path][:file]
		if uploaded_file.nil?
			flash.now[:error] = "Please provide a file for import."
			render 'file'
		else
			if @new_tasks = parse_file(uploaded_file)
				flash.now[:success] = "CSV Import Successful, #{@new_tasks.size} lines found."
				render 'upload'
			else
				flash.now[:error] = "There was an error processing your file. You must have at least two rows in your file."
				render 'file'
			end
		end
	end
	
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
	
	def destroy
		@path.destroy
		flash[:success] = "Path successfully deleted."
		redirect_back_or_to paths_path
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
		
		def parse_file(uploaded_file)
			new_tasks = []
			parsed_file = CSV.parse(uploaded_file.read)
			if file_properly_formatted?(parsed_file)
				row_count = 0
				parsed_file.each do |row|
					if row_count != 0
						new_tasks << create_task(row)
					end
					row_count += 1
				end
				return new_tasks
			else
				return nil
			end
		end
		
		def file_properly_formatted?(parsed_file)
			file_header = parsed_file[0]
			if file_header[0] =~ /question/i &&
				file_header[1] =~ /correct answer/i &&
				file_header[2] =~ /wrong answer/i &&
				file_header[3] =~ /wrong answer/i &&
				file_header[4] =~ /wrong answer/i &&
				file_header[5] =~ /points/i
				return true
			else
				return false
			end
		end
		
		def create_task(row)
			t = Task.new
			t.question = row[0]
			t.answer1 = row[1]
			t.answer2 = row[2]
			t.answer3 = row[3]
			t.answer4 = row[4]
			t.correct_answer = 1
			t.points = row[5]
			return t.save
		end
end