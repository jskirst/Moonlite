class StoredResourcesController < ApplicationController
  before_filter :authenticate
  
  def create
    @stored_resource = StoredResource.new(params)
    if @stored_resource.save
      render json: { status: "success", id: @stored_resource.id, link: @stored_resource.obj.url }
    else
      render json: { status: "error", errors: @stored_resource.errors.full_messages.join(".") }
    end
  end
     
  def destroy
    @stored_resource = StoredResource.find(params[:id]).destroy
    render nothing: true
  end
end