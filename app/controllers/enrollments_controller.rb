class EnrollmentsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy
  
  def create
    @enrollment = current_user.enrollments.build(params[:enrollment])
    if @enrollment.save
      flash[:success] = "Successfully enrolled."
      redirect_to @enrollment.path
    else
      redirect_to root_path
    end
  end
  
  def destroy
    @enrollment = Enrollment.find_by_id(params[:id])
    @path = @enrollment.path
    @enrollment.destroy
    redirect_to @path
  end
  
  private
    def authorized_user
      @enrollment = Enrollment.find(params[:id])
      redirect_to root_path unless current_user?(@enrollment.user)
    end
end