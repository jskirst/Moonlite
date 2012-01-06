require 'spec_helper'

describe PointTransactionsController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@other_user = Factory(:user)
		@company = Factory(:company)
	end
	
	describe "access controller" do
		before(:each) do
			@point_transaction = Factory(:point_transaction, :user => @other_user)
		end
	
		describe "when not signed in" do
			it "should deny access to 'index'" do
				get :index
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @point_transaction
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @point_transaction
				response.should redirect_to signin_path
			end		

			it "should deny access to 'update'" do
				put :update, :id => @user
				response.should redirect_to signin_path
			end			
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				@company_user = Factory(:company_user, :company => @company, :user => @user)
				test_sign_in(@user)
				@attr = {:status => 1}
			end
			
			it "should deny access to 'index'" do
				get :index
				response.should redirect_to root_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @point_transaction
				response.should redirect_to root_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @point_transaction
				response.should redirect_to root_path
			end
			
			it "should deny access to 'update'" do
				put :update, :id => @point_transaction, :point_transaction => @attr
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@company_user = Factory(:company_user, :company => @company, :user => @user, :is_admin => "t")
				test_sign_in(@user)
				@attr = {:status => 1}
			end

			it "should deny access to 'index'" do
				get :index
				response.should redirect_to root_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @point_transaction
				response.should redirect_to root_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @point_transaction
				response.should redirect_to root_path
			end
			
			it "should deny access to 'update'" do
				put :update, :id => @point_transaction, :point_transaction => @attr
				response.should redirect_to root_path
				#response.should have_selector("div", :content => "You do not have sufficient privaledges")
			end
		end
		
		describe "when signed in as admin" do
			before(:each) do
				@user.toggle!(:admin)
				@attr = {:status => 1}
				test_sign_in(@user)
			end

			it "should allow access to 'index'" do
				get :index
				response.should be_success
			end
			
			it "should allow access to 'show'" do
				get :show, :id => @point_transaction
				response.should be_success
			end
			
			it "should allow access to 'edit'" do
				get :edit, :id => @point_transaction
				response.should be_success
			end
			
			it "should allow access to 'update'" do
				put :update, :id => @point_transaction, :point_transaction => @attr
				response.should redirect_to point_transactions_path
			end
		end
	end
	
	describe "GET 'index'" do
		before(:each) do
			@user.toggle!(:admin)
			test_sign_in(@user)
			pt1 = Factory(:point_transaction, :user => @other_user)
			pt2 = Factory(:point_transaction, :user => @other_user)
			pt3 = Factory(:point_transaction, :user => @other_user)
			@point_transactions = [pt1, pt2, pt3]
			
			30.times do
				@point_transactions << Factory(:point_transaction, :user => @other_user)
			end
		end
		
		it "should be successful" do
			get :index
			response.should be_success
		end
		
		it "should have the right title" do
			get :index
			response.should have_selector("title", :content => "All transactions")
		end
		
		it "should display all transactions" do
			get :index
			@point_transactions[0..2].each do |pt|
				response.should have_selector("li", :content => pt.id.to_s)
			end
		end
		
		it "should paginate transactions" do
			get :index
			response.should have_selector("div.pagination")
			response.should have_selector("span.disabled", :content => "Previous")
			response.should have_selector("a", :href => "/point_transactions?page=2", :content => "2")
		end
	end
	
	describe "Get 'show'" do
		before(:each) do
			@user.toggle!(:admin)
			test_sign_in(@user)
			@point_transaction = Factory(:point_transaction, :user => @other_user)
		end
		
		it "should find the right transaction" do
			get :show, :id => @point_transaction
			assigns(:point_transaction).should == @point_transaction
		end
		
		it "should have the transactions's id in the title" do
			get :show, :id => @point_transaction
			response.should have_selector("title", :content => "#"+@point_transaction.id.to_s)
		end
		
		it "should display the user's name " do
			get :show, :id => @point_transaction
			response.should have_selector("a", :content => @point_transaction.user.name)
		end
		
		it "should display the transaction point balance" do
			get :show, :id => @point_transaction
			response.should have_selector("p", :content => @point_transaction.points.to_s)
		end
	end
	
	describe "GET 'edit'" do
		before(:each) do
			@user.toggle!(:admin)
			test_sign_in(@user)
			@point_transaction = Factory(:point_transaction, :user => @other_user)
		end

		it "should have the transactions's id in the title" do
			get :edit, :id => @point_transaction
			response.should have_selector("title", :content => "#"+@point_transaction.id.to_s)
		end
	end
	
	describe "PUT 'update'" do
		before(:each) do
			@user.toggle!(:admin)
			test_sign_in(@user)
			@point_transaction = Factory(:point_transaction, :user => @other_user)
		end
		
		describe "Failure" do
			before(:each) do
				@attr = {:status => ""}
			end
			
			it "should render the edit page" do
				put :update, :id => @point_transaction,  :point_transaction => @attr
				response.should render_template('edit')
			end
			
			it "should have the right title" do
				put :update, :id => @point_transaction,  :point_transaction => @attr
				response.should have_selector("title", :content => "#"+@point_transaction.id.to_s)
			end
			
			it "should have an error message" do
				put :update, :id => @point_transaction, :point_transaction => @attr
				response.should have_selector("div", :id => "error_explanation")
			end
		end
		
		describe "Success" do
			before(:each) do
				@attr = {:status => 1}
			end
			
			it "Should change user successfully" do
				put :update, :id => @point_transaction, :point_transaction => @attr
				@point_transaction.reload
				@point_transaction.status.should == @attr[:status]
			end
			
			it "Should redirect to index" do
				put :update, :id => @point_transaction, :point_transaction => @attr
				response.should redirect_to point_transactions_path
			end
			
			it "Should have a success message" do
				put :update, :id => @point_transaction, :point_transaction => @attr
				flash[:success].should =~ /updated/i
			end
		end
	end
end
