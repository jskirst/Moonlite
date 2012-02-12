class SectionsController < ApplicationController
  include OrderHelper
	before_filter :authenticate
	before_filter :company_admin, :except => [:continue, :show]
	
	def new
		@section = Section.new
		@title = "New section"
		@path_id = params[:path_id]
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
					redirect_to edit_path_path(@path, :m => "sections")
				end
			else
				@title = "New section"
				@form_title = @title
				@path_id = @path.id
				render "new"
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
		@section = Section.find(params[:id])
		@path_id = @section.path_id
		if params[:m] == "tasks"
			@tasks = @section.tasks
      @reorder = true if params[:a] == "reorder"
			render "edit_tasks"
		elsif params[:m] == "settings"
			render "edit_settings"
		end
	end
	
	def update
		@section = Section.find(params[:id])
		if @section.update_attributes(params[:section])
			flash[:success] = "Section successfully updated."
			render "edit"
		else
			@title = "Edit"
			render "edit"
		end
	end
  
  def reorder_tasks
    @section = Section.find(params[:id])
    old_order = @section.tasks.map { |t| [t.id, t.position] }
    new_order = params[:tasks][:positions].map { |id, position| [id.to_i, position.to_i] }
    revised_order = reorder(old_order, new_order)
    revised_order.each do |t|
      @section.tasks.find(t[0]).update_attribute(:position, t[1])
    end
    redirect_to edit_section_path(@section, :m => "tasks")
  end
	
	def destroy
		@section = Section.find(params[:id])
		@section.destroy
		flash[:success] = "Section successfully deleted."
		redirect_back_or_to edit_path_path(@section.path, :m => "sections")
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