class IdeasController < ApplicationController
  before_filter :authenticate, except: [:index, :show]
  before_filter :load_resource, except: [:index, :new, :create]
  before_filter :authorize_resource, only: [:edit, :update, :destroy]
  
  def index
    @compact_social = true
    @sort = params[:sort] || "vote_count"
    @ideas = Idea.order("#{@sort} DESC")
    @idea_votes = current_user.idea_votes.collect &:owner_id
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
    else
      flash[:error] = @idea.errors.full_messages.join(".")
    end
    render "form"
  end
  
  def new
    @idea = current_user.ideas.new
    render "form"
  end
  
  def create
    @idea = current_user.ideas.new(params[:idea])
    if @idea.save
      redirect_to ideas_path, notice: "Your idea has been submitted."
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