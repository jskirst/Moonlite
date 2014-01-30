class PersonasController < ApplicationController
  before_filter :authenticate
  before_filter :get_from_id, only: [:show, :edit, :preview, :destroy]
  before_filter :authorized, only: [:index, :edit, :update, :new, :create, :destroy]
  
  def index
    @mode = "personas"
    @personas = Persona.all
  end
  
  def show
    render partial: "show"
  end
  
  def edit
    render "form"
  end
  
  def update
    @persona = Persona.find(params[:id])
    @persona.name = params[:persona][:name]
    @persona.description = params[:persona][:description]
    @persona.image_url = params[:persona][:image_url]
    if params[:persona][:paths]
      @persona.criteria = params[:persona][:paths].collect { |id, state| id }
    else
      @persona.criteria = []
    end
    @persona.save
    redirect_to personas_path
  end
  
  def new
    @paths = Path.all
    @persona = Persona.new
    render "form"
  end
  
  def create
    @persona = Persona.new(params[:persona])
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
  
  def explore
    if request.xhr?
      @personas = Persona.includes(:path_personas).all
      render partial: "explore"
    else
      redirect_to root_url
    end
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