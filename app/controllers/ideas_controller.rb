class IdeasController < ApplicationController
  before_filter :authenticate, except: [:index, :ideas, :bugs, :show]
  before_filter :load_resource, except: [:index, :ideas, :bugs, :idea, :bug, :create]
  before_filter :authorize_resource, only: [:edit, :update, :destroy]
  
  def index
    redirect_to ideas_path
  end
  
  def ideas
    @compact_social = true
    @sort = params[:sort] || "created_at"
    @ideas = Idea.where(idea_type: Idea::IDEA).order("#{@sort} DESC")
    @idea_votes = current_user.idea_votes.collect &:owner_id if current_user
    render "index"
  end
  
  def bugs
    @compact_social = true
    @sort = params[:sort] || "created_at"
    @ideas = Idea.where(idea_type: Idea::BUG).order("#{@sort} DESC")
    @idea_votes = current_user.idea_votes.collect &:owner_id if current_user
    render "index"
  end
  
  def show
    @ideas = [Idea.find(params[:id])]
    @compact_social = false
    render "index"
  end
  
  def edit
    @idea = Idea.find(params[:id])
    render "form"
  end
  
  def update
    @idea = Idea.find(params[:id])
    @idea.title = params[:idea][:title]
    @idea.description = params[:idea][:description]
    if @idea.save
      flash[:success] = "Changes saved."
      redirect_to ideas_path
    else
      flash[:error] = @idea.errors.full_messages.join(".")
      render "form"
    end
  end
  
  def idea
    @idea = current_user.ideas.new(idea_type: Idea::IDEA)
    render "form"
  end
  
  def bug
    @idea = current_user.ideas.new(idea_type: Idea::BUG)
    render "form"
  end
  
  def create
    @idea = current_user.ideas.new(params[:idea])
    if @idea.save
      flash[:alert] = "You're idea was created."
      redirect_to @idea
    else
      flash[:alert] = @idea.errors.full_messages.join(". ")
      render "form" 
    end
  end
  
  def destroy
    @idea.destroy
    flash[:success] = "Idea successfully deleted."
    redirect_to ideas_path
  end
  
  def vote
    existing_vote = current_user.idea_votes.find_by_owner_id(@idea.id)
    if existing_vote
      existing_vote.destroy
      @idea.decrement_vote_count
    else
      current_user.idea_votes.create!(owner_id: @idea.id)
      @idea.increment_vote_count
    end
    render json: { status: "success" }
  end
  
  private
  
  def load_resource
    @idea = Idea.find(params[:id])
  end
 
  def authorize_resource
    unless @idea.creator == current_user
      raise "Access Denied: Cannot access vote"
    end
  end
end