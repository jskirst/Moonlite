require 'spec_helper'

describe UserRollsController do
  render_views
  
  before(:each) do
    @company = FactoryGirl.create(:company)
    @regular_user_roll = FactoryGirl.create(:user_roll, :company => @company, :enable_administration => "f")
    @admin_user_roll = FactoryGirl.create(:user_roll, :company => @company)
    @user = FactoryGirl.create(:user, :company => @company, :user_roll => @regular_user_roll)
    
    @category = FactoryGirl.create(:category, :company => @company)
    @path = FactoryGirl.create(:path, :user => @user, :company => @user.company, :category => @categoy)
    @section = FactoryGirl.create(:section, :path => @path)
    @task1 = FactoryGirl.create(:task, :section => @section, :position => 1)
    
    @attr = {
      :name => "New Role", 
      :enable_administration => true
    }
  end
  
  describe "access controller" do
    describe "when not signed in" do
      it "should deny access to all functionality" do
        get :new
        response.should redirect_to signin_path
        
        post :create, :user_roll => @attr
        response.should redirect_to signin_path
        
        get :edit, :id => @admin_user_roll
        response.should redirect_to signin_path
        
        put :update, :id => @admin_user_roll, :user_roll => @attr
        response.should redirect_to signin_path
        
        delete :destroy, :id => @admin_user_roll
        response.should redirect_to signin_path
      end
    end
    
    describe "when signed in as a regular user" do
      before(:each) do
        test_sign_in(@user)
      end
      
      it "should deny access to all functionality" do
        get :new
        response.should redirect_to root_path
        
        post :create, :user_roll => @attr
        response.should redirect_to root_path
        
        get :edit, :id => @admin_user_roll
        response.should redirect_to root_path
        
        put :update, :id => @admin_user_roll, :user_roll => @attr
        response.should redirect_to root_path
        
        delete :destroy, :id => @admin_user_roll
        response.should redirect_to root_path
      end
    end
    
    describe "when signed in as company admin" do
      before(:each) do
        @user.user_roll = @admin_user_roll
        @user.save
        test_sign_in(@user)
      end
      
      it "should allow access to all functionality" do
        get :new
        response.should be_success
        
        get :edit, :id => @admin_user_roll
        response.should be_success
        
        put :update, :id => @admin_user_roll, :user_roll => @attr
        response.should redirect_to user_rolls_path
        flash[:success].should =~ /updated/i
        
        post :create, :user_roll => @attr
        response.should redirect_to user_rolls_path
        flash[:success].should =~ /created/i
        
        delete :destroy, :id => @regular_user_roll
        response.should redirect_to user_rolls_path
        flash[:success].should =~ /removed/i
      end
    end
  end
  
  describe "actions" do
    before(:each) do
      @user.user_roll = @admin_user_roll
      @user.save
      test_sign_in(@user)
    end
    
    describe "GET 'new'" do
      it "should be successful" do
        response.should be_success
      end
    end
    
    describe "POST 'create'" do
      describe "failure" do
        before(:each) do
          @attr = @attr.merge(:name => "")
        end
      
        it "should not create a user roll" do
          lambda do
            post :create, :user_roll => @attr
          end.should_not change(UserRoll, :count)
        end
        
        it "should take you back to the new page" do
          post :create, :user_roll => @attr
          response.should render_template("form")
        end
      end
      
      describe "success" do
        it "should create a new user roll" do
          lambda do
            post :create, :user_roll => @attr
          end.should change(UserRoll, :count).by(1)    
        end
      end
    end
    
    describe "GET 'edit'" do
      it "should be successful" do
        get :edit, :id => @admin_user_roll
        response.should be_success
        response.should have_selector("title", :content => "Edit")
      end
    end
    
    describe "PUT 'update'" do
      describe "Failure" do
        before(:each) do
          @attr = @attr.merge(:name => "")
        end
        
        it "should render the edit page" do
          put :update, :id => @admin_user_roll, :user_roll => @attr
          response.should render_template("form")
        end
        
        it "should have an error message" do
          put :update, :id => @admin_user_roll, :user_roll => @attr
          response.should have_selector("p", :content => "The were problems with the following fields")
        end
      end
      
      describe "Success" do
        before(:each) do
          @attr = @attr.merge(:name => "Changed name", :enable_leaderboard => false)
        end
      
        it "Should change user roll successfully" do
          put :update, :id => @admin_user_roll, :user_roll => @attr
          @admin_user_roll.reload
          @admin_user_roll.name.should == @attr[:name]
          @admin_user_roll.enable_leaderboard.should == @attr[:enable_leaderboard]
        end
        
        it "Should redirect to index page" do
          put :update, :id => @admin_user_roll, :user_roll => @attr
          response.should redirect_to user_rolls_path
        end
        
        it "Should have a success message" do
          put :update, :id => @admin_user_roll, :user_roll => @attr
          flash[:success].should =~ /updated/i
        end
      end
    end
    
    describe "DELETE 'destroy'" do
      describe "failure when there are still active users" do
        it "should not delete the roll" do
          lambda do
            delete :destroy, :id => @admin_user_roll
          end.should_not change(UserRoll, :count)
        end
      end
      
      describe "success" do
        it "should destroy the user roll" do
          lambda do
            delete :destroy, :id => @regular_user_roll
          end.should change(UserRoll, :count).by(-1)
        end
        
        it "should redirect to the index" do
          delete :destroy, :id => @regular_user_roll
          response.should redirect_to user_rolls_path
        end
      end
    end
  end
end
  