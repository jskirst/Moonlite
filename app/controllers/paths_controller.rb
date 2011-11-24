require 'csv'
class PathsController < ApplicationController
	before_filter :authenticate
	before_filter :authorized_user, :only => [:edit, :update, :destroy, :file, :upload]
	
	def new
		@path = Path.new
		@title = "New Path"
	end
	
	def edit
		@title = "Edit"
	end

	def create
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
		if !params[:path][:file].nil?
			@parsed_file = CSV.parse(params[:path][:file])
			if @parsed_file.length <= 1
				flash.now[:error] = "There was an error processing your file. You must have at least two rows in your file."
				render 'file'
			else
				@row_count = 0
				@parsed_file.each  do |row|
					@row_count += 1
				end
				flash.now[:message] = "CSV Import Successful, #{@row_count} lines found."
			end
		else
			flash.now[:error] = "Please provide a file for import."
			render 'file'
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
end