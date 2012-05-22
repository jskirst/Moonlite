require 'spec_helper'

describe InfoResourcesController do
  render_views
  
  before(:each) do
    @company = FactoryGirl.create(:company)
    @regular_user_roll = FactoryGirl.create(:user_roll, :company => @company, :enable_administration => "f", :enable_user_creation => "f")
    @admin_user_roll = FactoryGirl.create(:user_roll, :company => @company)
    @user = FactoryGirl.create(:user, :company => @company, :user_roll => @regular_user_roll)
    
    @category = FactoryGirl.create(:category, :company => @company)
    @path = FactoryGirl.create(:path, :user => @user, :company => @company, :category => @category)
    @section = FactoryGirl.create(:section, :path => @path)
    @task = FactoryGirl.create(:task, :section => @section)
    
    @file = fixture_file_upload('files/test_pic.jpg', 'image/jpg')
    
    @attr = { :description => "New description", :file_field => @file,  :task_id => @task.id }
  end
  
  describe "access controller" do
    describe "when not signed in" do
      it "should deny access to all functionality" do
        @info_resource = InfoResource.create!(@attr)
      
        get :new, :task_id => @task
        response.should redirect_to signin_path
        post :create, :info_resource => @attr
        response.should redirect_to signin_path
        delete :destroy, :id => @info_resource
        response.should redirect_to signin_path
      end
    end
    
    describe "when signed-in as regular user" do
      it "should deny access to all functionality" do
        @info_resource = InfoResource.create!(@attr)
        test_sign_in(@user)
      
        get :new, :task_id => @task
        response.should redirect_to root_path
        post :create, :info_resource => @attr
        response.should redirect_to root_path
        delete :destroy, :id => @info_resource
        response.should redirect_to root_path
      end
    end
    
    describe "when signed-in as path creator" do
      before(:each) do
        @user.user_roll = @admin_user_roll
        test_sign_in(@user)
      end
      
      it "should allow access to :new" do
        get :new, :task_id => @task
        response.should be_success
      end
      
      it "should allow access to :create" do
        post :create, :info_resource => @attr
        response.should redirect_to edit_section_path(@section, :m => "tasks")
      end

      # it "should allow access to :destroy" do
        # delete :destroy, :id => @info_resource
        # response.should redirect_to edit_section_path(@section, :m => "tasks")
      # end
    end
  end
  
  describe "actions" do
    before(:each) do
      @user.user_roll = @admin_user_roll
      test_sign_in(@user)
    end
    
    describe "GET 'new'" do
      it "should be successful" do
        get :new, :task_id => @task
        response.should be_success
        response.should have_selector("title", :content => "New Image")
      end
    end
    
    describe "POST 'create'" do
      # describe "failure" do
        # it "should not create a info_resource" do
          # lambda do
            # post :create, :info_resource => {:task_id => @task, :file_field => "aaa"}  
          # end.should_not change(InfoResource, :count)
        # end
        
        # it "should take you back to the new info_resource page" do
          # post :create, :info_resource => {:task_id => @task, :file_field => "aaa"}  
          # response.should render_template("new")
        # end
      # end
      
      describe "success" do
        it "should create a info_resource" do
          lambda do
            post :create, :info_resource => @attr
          end.should change(InfoResource, :count).by(1)    
        end
        
        it "should redirect to the path page" do
          post :create, :info_resource => @attr
          response.should redirect_to edit_section_path(@section, :m => "tasks")
        end
        
        it "should have a flash message" do
          post :create, :info_resource => @attr
          flash[:success].should =~ /image added/i
        end
      end
    end
    
    describe "DELETE 'destroy'" do
      before(:each) do
        @info_resource = InfoResource.create!(@attr)
      end
      
      it "should destroy the info_resource" do
        lambda do
          delete :destroy, :id => @info_resource
        end.should change(InfoResource, :count).by(-1)
      end
    end
    
  end
end
  