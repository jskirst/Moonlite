require 'csv'
class PathsController < ApplicationController
	before_filter :authenticate
	before_filter :authorized_user, :only => [:edit, :update, :destroy, :file, :upload]
	
	def index
		@title = "All Paths"
		@paths = Path.paginate(:page => params[:page], :conditions => ["paths.company_id = ?", current_user.company.id])
	end
	
	def new
		@path = Path.new
		@title = "New Path"
	end
	
	def edit
		@title = "Edit"
	end

	def create
		params[:path][:company_id] = current_user.company.id
		@path = current_user.paths.build(params[:path])
		if @path.save
			flash[:success] = "Path created."
			redirect_to root_path
		else
			@title = "New Path"
			render 'new'
		end
	end
	
	def update
		if @path.update_attributes(params[:path])
			flash[:success] = "Changes saved."
			redirect_to @path
		else
			@title = "Edit Path"
			render 'edit'
		end
	end
	
	def show
		@path = Path.find(params[:id])
		@title = @path.name
		@remaining_tasks = @path.tasks_until_next_rank(current_user)
		@current_rank = @path.get_user_rank(current_user)
		@next_rank = @path.get_user_rank(current_user) + 1
		@info_resources = @path.info_resources
		@achievements = @path.achievements.all(:limit => 5)
	end
	
	def continue
		@path = Path.find(params[:id])
		if current_user.enrolled?(@path)
			@count = Integer(params[:count] || 0)
			@max = Integer(params[:max] || 5)
			@quiz_session = params[:quiz_session] || DateTime.now
			@quiz_session = Time.parse(@quiz_session.to_s)
			remaining_tasks = @path.remaining_tasks(current_user)
			
			if @max > remaining_tasks
				@max = remaining_tasks
			end
			
			if @count >= @max
				@title = "Results"
				@answers = CompletedTask.find(:all, :conditions => ["user_id=? AND quiz_session=?", current_user.id, @quiz_session])
				if !@answers.empty?
					@correct_answers = 0
					@total_answers = 0
					@answers.each do |a|
						if a.status_id < 2
							@total_answers += 1
						end
						if a.status_id == 1
							@correct_answers += 1
						end
					end
				end
				render "results"
			else
				@title = @path.name
				@task = @path.next_task(current_user)
			end
		else
			redirect_to @path
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
			@paths = Path.find(:all, :conditions => ["is_public = ? and name LIKE ?", true, "%#{@query}%"])
		end
	end
	
	def review
		@title = "Review purchase"
		if !@path = Path.find_by_id(params[:id])
			flash[:error] = "No path found for the argument supplied."
			redirect_to root_path and return
		elsif !@path.is_public
			flash[:error] = "This path is not available for purchase."
			redirect_to root_path and return
		end
	end
	
	def purchase
		if !@path = Path.find_by_id(params[:id])
			flash[:error] = "No path found for the argument supplied."
			redirect_to root_path and return
		elsif !@path.is_public
			flash[:error] = "This path is not available for purchase."
			redirect_to root_path and return
		else
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
			@path.tasks.each do |t|
				purchased_path.tasks.create!(
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
			@title = "Purchase successful"
			flash[:success] = "Purchase successful. Enjoy!."
		end
	end
	
	def destroy
		@path.destroy
		redirect_back_or_to root_path
	end
	
	private
		def authorized_user
			@path = Path.find(params[:id])
			if !current_user?(@path.user)
				redirect_to root_path
				flash[:error] = "You do not have the ability to change this path."
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