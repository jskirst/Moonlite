class CustomStylesController < ApplicationController
  before_filter :authenticate
  before_filter :get_style
  before_filter :has_access?
  
  def show
  end
  
  def edit
  end
  
  def update
    if @custom_style.update_attributes(params[:custom_style])
      redirect_to @custom_style, notice: "Custom style updated."
    else
      render "edit"
    end
  end
  
  private
    def get_style
      @custom_style = current_company.custom_style
      raise "nil custom style" if @custom_style.nil?
    end
  
    def has_access?
      unless @enable_administration
        redirect_to root_path, alert: "You do not have the ability to set custom styles for your organization."
      end
    end
end