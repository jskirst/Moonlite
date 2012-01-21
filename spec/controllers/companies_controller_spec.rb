require 'spec_helper'

describe CompaniesController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@company = @user.company
	end
	
	describe "access controller" do
		describe "when not signed in" do
			it "should deny access to 'new'" do
				get :new
				response.should redirect_to(signin_path)
			end
		
			it "should deny access to 'create'" do
				post :create
				response.should redirect_to(signin_path)
			end
			
			it "should deny access to 'index'" do
				get :index
				response.should redirect_to(signin_path)
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @company
				response.should redirect_to(signin_path)
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @company
				response.should redirect_to(signin_path)
			end			
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user)
			end
			
			it "should deny access to 'new'" do
				get :new
				response.should redirect_to root_path
			end
		
			it "should deny access to 'create'" do
				post :create
				response.should redirect_to root_path
			end
			
			it "should deny access to 'index'" do
				get :index
				response.should redirect_to root_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @company
				response.should redirect_to root_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @company
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as admin" do
			before(:each) do
				@user.toggle!(:admin)
				@attr = {:name => "Changed"}
				test_sign_in(@user)
			end
			
			it "should allow access to 'new'" do
				get :new
				response.should be_success
			end
		
			it "should allow access to 'create'" do
				post :create, :company => @attr
				response.should redirect_to Company.last
			end
			
			it "should allow access to 'index'" do
				get :index
				response.should be_success
			end
			
			it "should allow access to 'show'" do
				get :show, :id => 1
				response.should be_success
			end
			
			it "should allow access to 'edit'" do
				get :edit, :id => 1
				response.should be_success
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@user.company_user.toggle!(:is_admin)
				@attr = {:name => "Changed"}
				test_sign_in(@user)
			end
			
			it "should deny access to 'new'" do
				get :new
				response.should redirect_to root_path
			end
		
			it "should deny access to 'create'" do
				post :create
				response.should redirect_to root_path
			end
			
			it "should deny access to 'index'" do
				get :index
				response.should redirect_to root_path
			end
			
			it "should allow access to 'show'" do
				get :show, :id => 1
				response.should be_success
			end
			
			it "should allow access to 'edit'" do
				get :edit, :id => 1
				response.should be_success
			end
		end
	end

	describe "actions" do
		before(:each) do
			@user.toggle!(:admin)
			@user.company_user.toggle!(:is_admin)
			test_sign_in(@user)
		end

		describe "GET 'new'" do
			it "should be successful" do
				get :new
				response.should be_success
			end

			it "should have right title" do
				get :new
				response.should have_selector("title", :content => "Company Registration")
			end
		end
		
		describe "POST 'create'" do
			describe "failure" do
				before(:each) do
					@attr = {:name => ""}
				end
				
				it "should not create a company" do
					lambda do
						post :create, :company => @attr
					end.should_not change(Company, :count)
				end
				
				it "should have the right title" do
					post :create, :company => @attr
					response.should have_selector("title", :content => "Company Registration")
				end
				
				it "should render the new page" do
					post :create, :company => @attr
					response.should render_template("new")
				end
			end
			
			describe "success" do
				before(:each) do
					@attr = {:name => "Test Company"}
				end
				
				it "should save new company successfully" do
					lambda do
						post :create, :company => @attr
					end.should change(Company, :count).by(1)
				end
				
				it "should redirect to right company account" do
					post :create, :company => @attr
					response.should redirect_to(company_path(assigns(:company)))
				end
				
				it "should have a welcome message" do
					post :create, :company => @attr
					flash[:success].should =~ /Welcome to your company account/i
				end
			end
		end
		
		describe "Get 'show'" do
			it "should be successful" do
				get :show, :id => @company
				response.should be_success
			end
			
			it "should find the right user" do
				get :show, :id => @company
				assigns(:company).should == @company
			end
			
			it "should have the user's name in the title" do
				get :show, :id => @company
				response.should have_selector("title", :content => @company.name)
			end
			
			it "should have the user's name in the header" do
				get :show, :id => @company
				response.should have_selector("h1", :content => @company.name)
			end
			
			describe "associated users" do
				describe "when they don't exist" do
					before(:each) do
						@no_user_company = Factory(:company)
					end
					
					it "should display a message saying no registered users exist" do
						get :show, :id => @no_user_company
						response.should have_selector("p", :content => "not have any users")
					end
					
					it "should display a message saying no unregistered users exist" do
						get :show, :id => @no_user_company
						response.should have_selector("p", :content => "no outstanding user invitations")
					end
				end
				
				describe "when they exist" do
					before(:each) do
						@other_user1 = Factory(:user, :email => "other_user1@testing.com", :name => "Other user1", :company_user => nil)
						@other_user2 = Factory(:user, :email => "other_user2@testing.com", :name => "Other user2", :company_user => nil)
						@other_user3 = Factory(:user, :email => "other_user3@testing.com", :name => "Other user3", :company_user => nil)
					
						@unreg_company_user = Factory(:company_user, :email => "unreg@t.com", :company => @company, :user_id => nil)
						@company_user1 = Factory(:company_user, :email => @other_user1.email, :company => @company, :user_id => @other_user1.id)
						@company_user1 = Factory(:company_user, :email => @other_user2.email, :company => @company, :user_id => @other_user2.id)
						@company_user1 = Factory(:company_user, :email => @other_user3.email, :company => @company, :user_id => @other_user3.id)
						
						@users = [@other_user1, @other_user2, @other_user3]
					end
					
					it "should list unregistered users" do
						get :show, :id => @company
						response.should have_selector("li", :content => @unreg_company_user.email)
					end
					
					it "should list registered users" do
						get :show, :id => @company
						@users[0..2].each do |u|
							response.should have_selector("td", :content => u.name)
						end
					end
				end
			end
		end
		
		describe "GET 'edit'" do
			it "should be successful" do
				get :edit, :id => @user.company
				response.should be_success
			end

			it "should have right title" do
				get :edit, :id => @user.company
				response.should have_selector("title", :content => "Company Settings")
			end
		end
		
		describe "GET 'index'" do
			before(:each) do
				company1 = Factory(:company, :name => "Company1")
				company2 = Factory(:company, :name => "Company2")
				company3 = Factory(:company, :name => "Company3")
				@companies = [company1, company2, company3]
				
				30.times do
					@companies << Factory(:company, :name => Factory.next(:name))
				end
			end
			
			it "should be successful" do
				get :index
				response.should be_success
			end
			
			it "should have the right title" do
				get :index
				response.should have_selector("title", :content => "All companies")
			end
			
			it "should display all companies" do
				get :index
				@companies[0..2].each do |c|
					response.should have_selector("li", :content => c.name)
				end
			end
			
			it "should paginate companies" do
				get :index
				response.should have_selector("div.pagination")
				response.should have_selector("span.disabled", :content => "Previous")
				response.should have_selector("a", :href => "/companies?page=2", :content => "2")
			end
		end
	end
end
