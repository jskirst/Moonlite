# require 'spec_helper'

# describe AchievementsController do
  # render_views
  
  # before(:each) do
    # @user = FactoryGirl.create(:user)
    # @path = FactoryGirl.create(:path, :company => @user.company, :user => @user)
    # @section = FactoryGirl.create(:section, :path => @path)
    # @task1 = FactoryGirl.create(:task, :section => @section)
    # @task2 = FactoryGirl.create(:task, :section => @section)
    # @achievement = FactoryGirl.create(:achievement, :path => @path)
    
    # @attr = {
      # :name => "Replacement question", 
      # :description => "Replacement answer", 
      # :criteria => "fake", 
      # :points => 5,
      # :path_id => @path.id,
      # :tasks => [{ @task1.id => "on" }, { @task2.id => "on" }]
    # }
  # end
  
  # describe "access controller" do
    # describe "when not signed in" do
      # it "should deny access to 'new'" do
        # get :new, :path_id => @path.id
        # response.should redirect_to(signin_path)
      # end
    
      # it "should deny access to 'create'" do
        # post :create, :achievement => @attr
        # response.should redirect_to(signin_path)
      # end  
    # end
    
    # describe "when signed in as a regular user" do
      # before(:each) do
        # test_sign_in(@user)
      # end
      
      # it "should deny access to 'new'" do
        # get :new, :path_id => @path.id
        # response.should redirect_to root_path
      # end
    
      # it "should deny access to 'create'" do
        # post :create, :achievement => @attr
        # response.should redirect_to root_path
      # end
    # end
    
    # describe "when signed in as company admin" do
      # before(:each) do
        # @user.set_company_admin(true)
        # test_sign_in(@user)
      # end
      
      # it "should allow access to 'new'" do
        # get :new, :path_id => @path.id
        # response.should be_success
      # end
    
      # it "should allow access to 'create'" do
        # post :create, :achievement => @attr
        # response.should redirect_to edit_path_path(@path, :m => "achievements")
      # end
    # end
    
    # describe "when signed in as other company admin" do
      # before(:each) do
        # @other_user = FactoryGirl.create(:user)
        # @other_user.toggle!(:admin)
        # test_sign_in(@other_user)
      # end
      
      # it "should deny access to 'new'" do
        # get :new, :path_id => @path.id
        # response.should redirect_to root_path
      # end
    
      # it "should deny access to 'create'" do
        # post :create, :achievement => @attr
        # response.should redirect_to root_path
      # end
    # end
  # end
  
  # describe "actions" do
    # before(:each) do
      # @user.set_company_admin(true)
      # test_sign_in(@user)
    # end
    
    # describe "GET 'new'" do
      # it "should be successful" do
        # get :new, :path_id => @path.id
        # response.should be_success
      # end

      # it "should have right title" do
        # get :new, :path_id => @path.id
        # response.should have_selector("title", :content => "New")
      # end
    # end
    
    # describe "POST 'create'" do
      # describe "failure" do
        # before(:each) do
          # @attr = @attr.merge(:name => "", :description => "")
        # end
      
        # it "should not create a achievement" do
          # lambda do
            # post :create, :achievement => @attr  
          # end.should_not change(Achievement, :count)
        # end
        
        # it "should take you back to the new achievement page" do
          # post :create, :achievement => @attr
          # response.should render_template("new")
        # end
      # end
      
      # describe "success" do    
        # it "should create a task" do
          # lambda do
            # post :create, :achievement => @attr
          # end.should change(Achievement, :count).by(1)    
        # end
        
        # it "should redirect to the path page" do
          # post :create, :achievement => @attr
          # response.should redirect_to edit_path_path(@path, :m => "achievements")
        # end
        
        # it "should have a flash message" do
          # post :create, :achievement => @attr
          # flash[:success].should =~ /achievement created/i
        # end
      # end
    # end
  # end
# end
  