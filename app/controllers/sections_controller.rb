class SectionsController < ApplicationController
	before_filter :authenticate
	before_filter :company_admin, :except => [:continue, :show]
	
	def new
		@section = Section.new
		@title = "New section"
		@path_id = params[:path_id]
		@form_title = "New"
		render "section_form"
	end
	
	def create
		@path = Path.find_by_id(params[:section][:path_id])
		if @path.nil?
			flash[:error] = "No Path selected for section."
			redirect_to root_path and return
		else			
			@section = @path.sections.build(params[:section])
			if @section.save
				flash[:success] = "Section created."
				if params[:commit] == "Save and New"
					redirect_to new_section_path(:path_id => @path.id)
				else
					redirect_to @section
				end
			else
				@title = "New section"
				@form_title = @title
				@path_id = @path.id
				render "section_form"
			end
		end
	end
	
	def show
		@section = Section.find(params[:id])
		@path_name = @section.path.name
		@title = @section.name
	end
	
	def edit
		@title = "Edit section"
		@form_title = "Edit section"
		@section = Section.find(params[:id])
		@path_id = @section.path_id
		render "section_form"
	end
	
	def update
		@section = Section.find(params[:id])
		if @section.update_attributes(params[:section])
			flash[:success] = "Section successfully updated."
			redirect_to @section
		else
			@title = "Edit"
			@form_title = @title
			render "section_form"
		end
	end
	
	def destroy
		@section = Section.find(params[:id])
		@section.destroy
		flash[:success] = "Section successfully deleted."
		redirect_back_or_to @section.path
	end
	
	def continue
		@section = Section.find(params[:id])
		if current_user.enrolled?(@section.path)
			@quiz_session = Time.parse((params[:quiz_session] || DateTime.now).to_s)
			@remaining_tasks = @section.remaining_tasks(current_user)
			
			if @remaining_tasks == 0
				@title = "Results"
				@answers = CompletedTask.find(:all, :conditions => ["user_id=? AND quiz_session=?", current_user.id, @quiz_session])
				if !@answers.empty?
					@correct_answers = 0
					@total_answers = 0
					@answers.each do |a|
						@total_answers += (a.status_id < 2 ? 1 : 0)
						@correct_answers += (a.status_id == 1 ? 1 : 0)
					end
				end
				render "results"
			else
				@title = @section.name
				@task = @section.next_task(current_user)
			end
		else
			redirect_to @section
		end
	end
end