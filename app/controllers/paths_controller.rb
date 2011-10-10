class PathsController < ApplicationController
	before_filter :authenticate, :only => [:new, :create, :destroy, :show, :continue]
	before_filter :authorized_user, :only => :destroy
	
	def new
		@path = Path.new
		@title = "New Path"
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
	
	def show
		@path = Path.find(params[:id])
		@title = @path.name
		@tasks = @path.tasks
	end
	
	def continue
		@path = Path.find(params[:id])
		if current_user.enrolled?(@path)
			@title = @path.name
			@task = @path.next_task(current_user)
		else
			redirect_to @path
		end
	end
	
	def destroy
		@path.destroy
		redirect_back_or_to root_path
	end
	
	private
		def authorized_user
			@path = Path.find(params[:id])
			redirect_to root_path unless current_user?(@path.user)
		end
end