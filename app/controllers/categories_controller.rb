class CategoriesController < ApplicationController
  before_filter :authenticate
  before_filter :company_admin
  
  def new
    @title = "New Category"
    @category = Category.new
  end
  
  def create
    params[:category][:company_id] = current_user.company_id
    @category = Category.new(params[:category])
    if @category.save
      flash[:success] = "Category created."
      redirect_to edit_company_path(current_user.company)
    else
      @title = "New"
      render "new"
    end
  end
  
  def destroy
    @category = Category.find(params[:id])
    if @category.company_id == current_user.company_id
      @category.destroy
      flash[:success] = "Category successfully removed. Any paths with that have been transfered to the 'Unassigned' category."
      redirect_to edit_company_path(current_user.company)
    else
      alert_and_redirect
    end
  end
  
  private
    def alert_and_redirect
      flash[:error] = "You are not authorized to access the resources of that organization. You're actions have been reported."
      redirect_to root_path
    end
end