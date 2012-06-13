class CustomStylesController < ApplicationController
  before_filter :authenticate
  before_filter :get_custom_style_from_id
  before_filter :has_access?
  
  def show
  end
  
  def edit
  end
  
  def update
    if @custom_style.update_attributes(params[:custom_style])
      flash[:success] = "Custom style updated."
      redirect_to @custom_style
    else
      render "edit"
    end
  end
  
  private
    def get_custom_style_from_id
      @custom_style = current_user.company.custom_style
      if @custom_style.nil?
        flash[:error] = "This is not a valid custom style."
        redirect_to root_path
      else
        @company = @custom_style.company
      end
    end
  
    def has_access?
      unless @enable_administration
        flash[:error] = "You do not have the ability to set custom styles for your organization."
        redirect_to root_path
        return
      end
    end
end