class GroupsController < ApplicationController
  include NewsfeedHelper  
  
  before_filter :authenticate
  before_filter :load_resource
  
  def show    
    @title = "#{@group.name} Group"
    @users = @group.users.order "earned_points desc"
    @membership = @group.group_users.find_by_user_id(current_user)
    @url_for_newsfeed = newsfeed_group_path(@group)
    render "show"
  end
  
  def newsfeed
    render text: "asoidjfoiasf asflkjalsd"
  end
  
  def update
    @group.update_attributes(params[:group])
    redirect_to @group
  end
  
  def join
    @group.group_users.create! user: current_user
    redirect_to @group
  end
  
  def leave
    @group.group_users.find_by_user_id(current_user.id).delete
    redirect_to @group
  end
  
  
  private
  def load_resource
    @group = Group.find_by_permalink(params[:permalink]) if params[:permalink]
    @group = Group.find_by_permalink(params[:id]) if params[:id] && @group.nil?
    @group = Group.find_by_id(params[:id]) if params[:id] && @group.nil?
    redirect_to root_path unless @group
  end
end