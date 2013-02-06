class IdeasController < ApplicationController
  before_filter :authenticate, except: [:index, :show]
  before_filter :load_resource, except: [:index, :new, :create]
  before_filter :authorize_resource, only: [:edit, :update, :destroy]
  
  def index
    @compact_social = true
    @mode = "personas"
    @ideas = Idea.all
    @idea_votes = current_user.idea_votes.collect &:owner_id
  end
  
  def show
    @idea = Idea.find(params[:id]).include(:comments, :votes)
  end
  
  def edit
    @idea = Idea.find(params[:id])
  end
  
  def update
    @idea = Idea.find(params[:id])
    @idea.name = params[:idea][:title]
    @idea.name = params[:idea][:description]
    if @idea.save
      flash[:success] = "Fixed it."
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
    current_user.idea_votes.create!(owner_id: @idea.id)
    flash[:success] = "Idea successfully deleted."
    redirect_to ideas_path
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