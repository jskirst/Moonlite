class StoredResourcesController < ApplicationController
  before_filter :authenticate
  
  def destroy
    @stored_resource = StoredResource.find(params[:id])
    if @stored_resource.destroy
      flash[:success] = "Resource deleted."
    else
      flash[:error] = "Woops."
    end
    redirect_back_or_to root_path
  end
end