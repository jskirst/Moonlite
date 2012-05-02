require 'spec_helper'

describe UserTransactionsController do
	render_views
	
	before(:each) do
		@user = FactoryGirl.create(:user)
    @path = FactoryGirl.create(:path, :user => @user, :company => @user.company)
    @section = FactoryGirl.create(:section, :path => @path)
    @task = FactoryGirl.create(:task, :section => @section)
		@other_user = FactoryGirl.create(:user, :company => @user.company)
    @other_user.enroll!(@path)
		@user_transaction = FactoryGirl.create(:user_transaction, :task => @task, :user => @other_user)
	end
	
	describe "access controller" do
		describe "when not signed in" do
			it "should deny access to 'index'" do
				get :index
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @user_transaction
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @user_transaction
				response.should redirect_to signin_path
			end		

			it "should deny access to 'update'" do
				put :update, :id => @user
				response.should redirect_to signin_path
			end			
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user)
				@attr = {:status => 1}
			end
			
			it "should deny access to 'index'" do
				get :index
				response.should redirect_to root_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @user_transaction
				response.should redirect_to root_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @user_transaction
				response.should redirect_to root_path
			end
			
			it "should deny access to 'update'" do
				put :update, :id => @user_transaction, :user_transaction => @attr
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				test_sign_in(@user)
				@attr = {:status => 1}
			end

			it "should deny access to 'index'" do
				get :index
				response.should redirect_to root_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @user_transaction
				response.should redirect_to root_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @user_transaction
				response.should redirect_to root_path
			end
			
			it "should deny access to 'update'" do
				put :update, :id => @user_transaction, :user_transaction => @attr
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
				get :show, :id => @user_transaction
				response.should be_success
			end
			
			it "should allow access to 'edit'" do
				get :edit, :id => @user_transaction
				response.should be_success
			end
			
			it "should allow access to 'update'" do
				put :update, :id => @user_transaction, :user_transaction => @attr
				response.should redirect_to user_transactions_path
			end
		end
	end
	
	describe "actions" do
		before(:each) do
			@user.toggle!(:admin)
			test_sign_in(@user)
		end
	
		describe "GET 'index'" do
			before(:each) do
				pt1 = FactoryGirl.create(:user_transaction, :user => @other_user)
				pt2 = FactoryGirl.create(:user_transaction, :user => @other_user)
				pt3 = FactoryGirl.create(:user_transaction, :user => @other_user)
				@user_transactions = [pt1, pt2, pt3]
				
				30.times do
					@user_transactions << FactoryGirl.create(:user_transaction, :user => @other_user)
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
				@user_transactions[0..2].each do |pt|
					response.should have_selector("li", :content => pt.id.to_s)
				end
			end
			
			it "should paginate transactions" do
				get :index
				response.should have_selector("div.pagination")
				response.should have_selector("span.disabled", :content => "Previous")
				response.should have_selector("a", :href => "/user_transactions?page=2", :content => "2")
			end
		end
		
		describe "Get 'show'" do
			it "should find the right transaction" do
				get :show, :id => @user_transaction
				assigns(:user_transaction).should == @user_transaction
			end
			
			it "should have the transactions's id in the title" do
				get :show, :id => @user_transaction
				response.should have_selector("title", :content => "#"+@user_transaction.id.to_s)
			end
			
			it "should display the user's name " do
				get :show, :id => @user_transaction
				response.should have_selector("a", :content => @user_transaction.user.name)
			end
			
			it "should display the transaction point balance" do
				get :show, :id => @user_transaction
				response.should have_selector("p", :content => @user_transaction.amount.to_s)
			end
		end
		
		describe "GET 'edit'" do
			it "should have the transactions's id in the title" do
				get :edit, :id => @user_transaction
				response.should have_selector("title", :content => "#"+@user_transaction.id.to_s)
			end
		end
		
		describe "PUT 'update'" do
			describe "Failure" do
				before(:each) do
					@attr = {:status => ""}
				end
				
				it "should render the edit page" do
					put :update, :id => @user_transaction,  :user_transaction => @attr
					response.should render_template('edit')
				end
				
				it "should have the right title" do
					put :update, :id => @user_transaction,  :user_transaction => @attr
					response.should have_selector("title", :content => "#"+@user_transaction.id.to_s)
				end
				
				it "should have an error message" do
					put :update, :id => @user_transaction, :user_transaction => @attr
					response.should have_selector("div", :id => "error_explanation")
				end
			end
			
			describe "Success" do
				before(:each) do
					@attr = {:status => 1}
				end
				
				it "Should change user successfully" do
					put :update, :id => @user_transaction, :user_transaction => @attr
					@user_transaction.reload
					@user_transaction.status.should == @attr[:status]
				end
				
				it "Should redirect to index" do
					put :update, :id => @user_transaction, :user_transaction => @attr
					response.should redirect_to user_transactions_path
				end
				
				it "Should have a success message" do
					put :update, :id => @user_transaction, :user_transaction => @attr
					flash[:success].should =~ /updated/i
				end
			end
		end
	end
end
