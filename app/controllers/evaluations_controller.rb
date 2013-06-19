class EvaluationsController < ApplicationController
  
  before_filter :authenticate, except: [:take]

  def new
    @evaluation = Evaluation.new
    @paths = Persona.first.paths
    @title = "Create a new Evaluation"
    @show_footer = true
    @hide_background = true
  end
  
  def create
    @evaluation = current_user.evaluations.new(params[:evaluation])
    if @evaluation.save
      redirect_to create_confirmation_evaluation_path(@evaluation)
    else
      render "new"
    end
  end
  
  def create_confirmation
    @evaluation = current_user.evaluations.find(params[:id])
    @show_footer = true
    @hide_background = true
    render "create_evaluation_confirmation"
  end
  
  def take
    @evaluation = current_user.evaluations.find_by_permalink(params[:id])
    if not current_user
      cookies[:evaluation] = @evaluation.permalink
    end
    @show_footer = true
    @hide_background = true
    render "take_evaluation"
  end

  def take_confirmation
    @show_footer = true
    @hide_background = true
    @paths = Path.by_popularity(8).where("promoted_at is not ?", nil).to_a
    render "take_evaluation_confirmation"
  end

  def overview
    @show_footer = true
    @hide_background = true
    render "evaluations_overview"
  end

  def manager
    @show_footer = true
    @hide_background = true
    @evaluations = current_user.evaluations
    render "evaluation_manager"
  end
end