class EvaluationsController < ApplicationController
  
  before_filter :authenticate, except: [:take]

  def new
    @evaluation = Evaluation.new
    @title = "Create a new Evaluation"
    @show_footer = true
    @hide_background = true
    render "create_evaluation"
  end
  
  def create
    @evaluation = current_user.evaluations.new(params[:evaluations])
    if @evaluation.save
      render "create_evaluation_confirmation"
    else
      render "create_evaluation"
    end
  end
  
  def create_confirmation
    @show_footer = true
    @hide_background = true
    render "create_evaluation_confirmation"
  end
  
  def take
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