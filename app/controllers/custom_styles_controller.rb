class CustomStylesController < ApplicationController
  before_filter :authenticate
  before_filter :get_custom_style_from_id, :except => [:index, :new, :create]
  before_filter :has_access?
  
  def index
    @custom_style = current_user.company.custom_styles.first
    @company = current_user.company
  end
  
  def create
    @custom_style = current_user.company.custom_styles.new(params[:custom_style])
    if @custom_style.save
      flash[:success] = "Custom style created."
    else
      flash[:success] = "Could not create custom style. Please try again."
    end
    redirect_to custom_styles_path
  end
  
  def edit
    @mode = params[:m]
    if params[:m] == "core"
      @style = @custom_style.core_layout_styles
    else
      @style = @custom_style.add_on_styles
    end
    @title = "Edit Custom Style"
    @form_mode = "edit"
    render "form"
  end
  
  def update
    if @custom_style.update_attributes(params[:custom_style])
      flash[:success] = "Custom style updated."
      redirect_to custom_styles_path
    else
      @title = "Edit Custom Style"
      @form_mode = "edit"
      render "form"
    end
  end
  
  def destroy
    if @custom_style.destroy
      flash[:success] = "Custom style successfully removed."
    else
      flash[:error] = "Custom style could not be deleted. Please try again."
    end
    redirect_to custom_styles_path
  end
  
  private
    def get_custom_style_from_id
      @custom_style = current_user.company.custom_styles.find(params[:id])
      if @custom_style.nil?
        flash[:error] = "This is not a valid custom style."
        redirect_to root_path
      else
        @company = @custom_style.company
      end
    end
  
    def has_access?
      unless @enable_administration
        flash[:error] = "You do not have access to this functionality."
        redirect_to root_path
        return
      end
    end
end