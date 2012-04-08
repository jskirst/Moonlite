require 'net/http'
require 'uri'

class SectionsController < ApplicationController
  include OrderHelper
	before_filter :authenticate
	before_filter :company_admin, :except => [:continue, :show]
  before_filter :get_section_from_id, :except => [:new, :create, :continue, :generate]
  before_filter :verify_enrollment, :only => [:continue]

	def show
		@path_name = @section.path.name
		@title = @section.name
    @section_started = current_user.section_started?(@section)
    @info_resources = @section.info_resources
	end

# Begin Section Creation  
  
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
					redirect_to edit_section_path(:id => @section, :m => "instructions")
				end
			else
				@title = "New section"
				@form_title = @title
				@path_id = @path.id
				render "new"
			end
		end
	end

# Begin Section Edit
	
	def edit
		@title = "Edit section"
		@path_id = @section.path_id
    @mode = params[:m]
		if @mode == "tasks"
			@tasks = @section.tasks
      @reorder = true if params[:a] == "reorder"
			render "edit_tasks"
		elsif @mode == "settings"
			render "edit_settings"
		elsif @mode == "randomize"
      if @section.randomize_tasks
        flash[:success] = "Tasks randomly reordered."
      else
        flash[:error] = "There was a problem reordering your tasks."
      end
      @section.reload
      @tasks = @section.tasks
			render "edit_tasks"
		else
      render "edit_instructions"
    end
	end
	
	def update
    if params[:section][:is_published]
      if @section.tasks.size.zero?
        flash[:error] = "You need to create at least 1 task for this section before you can make it publicly available."
        @mode = "settings"
        render "edit_settings" 
        return
      end
    end
		if @section.update_attributes(params[:section])
			flash.now[:success] = "Section successfully updated."
      @mode = "instructions"
			redirect_to edit_section_path(@section, :m => "instructions")
		else
			@title = "Edit"
			render "edit_settings"
		end
	end
  
  def reorder_tasks
    old_order = @section.tasks.map { |t| [t.id, t.position] }
    new_order = params[:tasks][:positions].map { |id, position| [id.to_i, position.to_i] }
    revised_order = reorder(old_order, new_order)
    revised_order.each do |t|
      @section.tasks.find(t[0]).update_attribute(:position, t[1])
    end
    redirect_to edit_section_path(@section, :m => "tasks")
  end
	
	def destroy
		@section.destroy
		flash[:success] = "Section successfully deleted."
		redirect_to edit_path_path(@section.path, :m => "sections")
	end

# Begin Section Construction 
  
  def research
    @mode = params[:m]
    if params[:m] == "clear"
      if @section.update_attribute("instructions", nil)
        flash[:success] = "Instructions cleared."
      else
        flash[:error] = "Oops! An error occurred and we couldn't clear your instructions. Please try again."
      end
      redirect_to edit_section_path(@section, :m => "instructions")
    elsif params[:m] == "create"
      @topics = params[:topics].split(",")
      if params[:main_topic]
        @topics << @section.name
      end
      @topics = @topics.map {|t| t.strip}
      @quoted_topics = @topics.map {|t| '"'+t+'"'}
      
      @use_wikipedia = params[:use_wikipedia] ? true : false;
      @use_youtube = params[:use_youtube] ? true : false;
      @use_google_images = params[:use_google_images] ? true : false;
    elsif params[:m] == "topics"
      @answers = []
      @section.tasks.all.each do |t|
        @answers << t.describe_correct_answer
      end
      @answers = @answers.uniq.join(", ")
      render "research_settings"
    else
      @topics = []
      @quoted_topics = []
    end
  end
  
  def questions
    @title = "Generate Questions"
    @url = "http://ec2-50-19-152-110.compute-1.amazonaws.com:3000/generate"
    @limit = params[:limit]
    text = clean_text(@section.instructions)
    
    paragraphs = text.split("<p>")
    @split_paragraphs = []
    paragraphs.each do |p|
      split_paragraph = p.split(". ")
      sentences = []
      split_paragraph.each_index do |si|
        sentence = split_paragraph[si].chomp + "."
        if sentence.length > 35 
          sentences << sentence
        end
        if sentence.length > 160 || sentences.length >= 3
          @split_paragraphs << sentences.join(" ")
          sentences = []
        end
      end
      unless sentences.join(" ").length < 80
        @split_paragraphs << sentences.join(" ")
      end
    end
    @quoted_paragraphs = @split_paragraphs.map {|t| '"'+t+'"'}
  end
  
  def generate
    @text = params[:text]
    uri = URI.parse("http://ec2-50-19-152-110.compute-1.amazonaws.com:3000/generate")
    http = Net::HTTP.new(uri.host, uri.port)

    http.read_timeout = 90
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({'text' => @text})
    resp, @data = http.request(request)
    
    unless @data.nil?
      logger.debug @data
      respond_to do |format|
        format.json
      end
    end
  end
  
  def review
    @title = "Review Questions"
    raw_questions = params[:questions]
    @processed_questions = {}
    raw_questions.each do |key, value|
      value = value.split("?")
      question = value[0].to_s + "?"
      answer = value[1].to_s
      @processed_questions[key] = {:question => question, :answer1 => answer}
    end
    logger.debug "PQ:"
    logger.debug @processed_questions.to_s
  end
  
  def bulk_tasks
    raw_questions = params[:questions]
    @processed_questions = {}
    raw_questions.each do |key, values|
      new_task = @section.tasks.build(values.merge(:points => 10))
      unless new_task.save
        @processed_questions[key] = values.merge(:errors => new_task.errors.full_messages)
      end
    end
    if @processed_questions.size > 0
      flash[:error] = "Could not save the following tasks. Please review and resubmit."
      render "review"
    else
      flash[:success] = "All tasks successfully added!"
      redirect_to edit_section_path(@section, :m => "tasks")
    end
  end

# Begin Section Journey
  
  def continue
    @task = @section.next_task(current_user)
    if @task.nil?
      last_task = current_user.completed_tasks.includes(:section).where(["sections.id = ?", @section.id]).first(:order => "completed_tasks.id DESC")
      @answers = current_user.completed_tasks.joins(:task).where(["section_id = ?", last_task.task.section_id]).all
      if !@answers.empty?
        @total_answers = @answers.size
        @correct_answers = 0
        @answers.each {|a| @correct_answers += a.status_id}
      end
      @final_section = true if @path.next_section(@section).nil?
      render "results"
    else
      if params[:previous]
        @correct = (params[:previous] == "1" ? true : false)
      end
      @progress = @path.percent_complete(current_user) + 1
      @earned_points = @path.enrollments.where(["user_id = ?", current_user.id]).first.total_points
      @possible_points = 10
      @streak_points = @section.user_streak(current_user)
      
      @info_resource = @task.info_resource
      @title = @section.name
      unless params[:comments_on].nil?
        @comments_on = true
        @comments = @task.comments.all
        @comment = @task.comments.new
      end
    end
	end
  
  private
    def verify_enrollment
      if @section.nil?
        get_section_from_id
      end
      @path = @section.path
      unless current_user.enrolled?(@path)
        flash[:warning] = "You must be enrolled in a path before you can begin."
        redirect_to root_path
      end
    end
    
    def get_section_from_id
      @section = Section.find(params[:id], :include => :path)
    end
    
    def clean_text(text)
      text = text.gsub("This section will include questions on the following topics", "")
        .gsub("<b>","  ")
        .gsub("</b>","  ")
        .gsub("<sub>","")
        .gsub("</sub>","  ")
        .gsub(/<a[^>]*>/im,"  ")
        .gsub(/<\/a>/im,"  ")
        .gsub(/<li\b[^>]*>(.*?)<\/li>/im," ")
        .gsub(/<!--[^>]*-->/im,"")
        .gsub(/<[\/a-z123456]{2}[^>]*>/im," ")
        .gsub(/<[\/bi][^>]*>/im," ")
        .gsub(/\[[^\]]+\]/im," ")
        .gsub(/\([^\)]+\)/im," ")
        .gsub("&nbsp;"," ")
        .gsub("&quot;","")
        .gsub(/\r\n/," ")
        .gsub(/"/,"'")
      until text.gsub!(/\s\s/,"").nil?
        text = text.gsub(/\s\s/, " ")
      end
      text = text.gsub(" .", ".").gsub(" ,", ",")
      return text.strip.chomp
    end
end