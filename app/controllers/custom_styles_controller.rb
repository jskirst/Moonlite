class CustomStylesController < ApplicationController
  before_filter :authenticate
  before_filter :has_access?
  
  def show
    @mode = "styles"
    @custom_style = current_company.custom_style
  end
  
  def edit
    @custom_style = current_company.custom_style
  end
  
  def update
    @custom_style = current_company.custom_style
    if @custom_style.update_attributes(params[:custom_style])
      redirect_to @custom_style, notice: "Custom style updated."
    else
      render "edit"
    end
  end
  
  private
    def has_access?
      unless @enable_administration
        redirect_to root_path, alert: "You do not have the ability to set custom styles for your organization."
      end
    end
end