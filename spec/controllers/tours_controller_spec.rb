require 'spec_helper'

describe ToursController do
  render_views
  
  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  
  describe "access controller" do
    describe "when not signed in" do
      it "should deny access to 'index'" do
        get :index
        response.should redirect_to signin_path
      end
      
      it "should deny access to 'admin_tour'" do
        get :admin_tour, :id => 1
        response.should redirect_to signin_path
      end

      it "should deny access to 'user_tour'" do
        get :user_tour, :id => 1
        response.should redirect_to signin_path
      end
    end
    
    describe "when signed in as a regular user" do
      before(:each) do
        test_sign_in(@user)
      end
      
      it "should deny access to 'index'" do
        get :index
        response.should redirect_to user_tour_tour_path(1)
      end
      
      it "should deny access to 'admin_tour'" do
        get :admin_tour, :id => 1
        response.should redirect_to user_tour_tour_path(1)
      end
      
      it "should allow access to 'user_tour'" do
        get :user_tour, :id => 1
        response.should be_success
      end
    end
    
    describe "when signed in as company admin" do
      before(:each) do
        @user.set_company_admin(true)
        test_sign_in(@user)
      end
      
      it "should allow access to 'index'" do
        get :index
        response.should be_success
      end
      
      it "should allow access to 'admin_tour'" do
        get :admin_tour, :id => 1
        response.should be_success
      end
      
      it "should allow access to 'user_tour'" do
        get :user_tour, :id => 1
        response.should be_success
      end
    end
  end
end