class EvaluationsController < ApplicationController
  before_filter :authenticate, except: [:take]
  before_filter :load_group
  before_filter :authorize_group, except: [:take, :take_confirmation]
  before_filter { @show_footer = true and @hide_background = true }

  def index
    @evaluations = @group.evaluations.all
    @open_evaluations = @evaluations.select{ |e| e.closed_at.nil? }
    @closed_evaluations = @evaluations.select{ |e| e.closed_at }
  end
  
  def show
    @evaluation = @group.evaluations.find(params[:id])
  end
  
  def new
    @evaluation = @group.evaluations.new
    @paths = Persona.first.paths
    @title = "Create a new Evaluation"
  end
  
  def create
    @evaluation = @group.evaluations.new(params[:evaluation])
    @evaluation.user_id = current_user.id
    if @evaluation.save
      redirect_to create_confirmation_group_evaluation_path(@group, @evaluation)
    else
      @paths = Persona.first.paths
      @title = "Create a new Evaluation"
      render "new"
    end
  end
  
  def create_confirmation
    @evaluation = current_user.evaluations.find(params[:id])
  end
  
  def take
    @evaluation = current_user.evaluations.find_by_permalink(params[:id])
    cookies[:evaluation] = @evaluation.permalink if not current_user
  end

  def take_confirmation
    @evaluation = current_user.evaluations.find(params[:id])
    @paths = Path.by_popularity(8).where("promoted_at is not ?", nil).to_a
  end
  
  private
  
  def load_group
    @group = Group.find(params[:group_id])
  end
  
  def authorize_group
    @group_user = @group.group_users.find_by_user_id(current_user.id)
    raise "Access Denied: Not Group Admin" unless @group_user.is_admin?
  end
end