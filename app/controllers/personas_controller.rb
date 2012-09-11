class PersonasController < ApplicationController
  before_filter :authenticate
  before_filter :company_admin, :except => [:show]
  before_filter :get_from_id, :except => [:new, :create, :index]
  before_filter :authorized, :except => [:show]
  
  def index
    @personas = current_company.personas
  end
  
  def new
    @paths = current_company.paths.all
    @persona = Persona.new
  end
  
  def create
    @persona = current_user.company.personas.new(params[:persona])
    @persona.criteria = params[:persona][:paths].collect { |id, state| id }
    if @persona.save
      redirect_to personas_path, notice: "Achievement created."
    else
      redirect_to new_persona_path, alert: @persona.errors.full_messages.join(". ")
    end
  end
  
  def destroy
    @persona.destroy
    flash[:success] = "Persona successfully deleted."
    redirect_to personas_path
  end
  
  def preview
    render partial: "preview", locals: { persona: @persona }
  end
  
  private
    def get_from_id
      @persona = Persona.find(params[:id])
    end
   
    def authorized
      unless @enable_administration
        redirect_to root_path, alert: "You are not authorized."
      end
    end
end