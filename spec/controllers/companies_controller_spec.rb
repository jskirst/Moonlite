require 'spec_helper'

describe CompaniesController do
	render_views
	
	describe "access controller" do
		it "should deny access to 'new'" do
			get :new
			response.should redirect_to(signin_path)
		end
	
		it "should deny access to 'create'" do
			post :create
			response.should redirect_to(signin_path)
		end
		
		it "should deny access to 'show'" do
			post :create
			response.should redirect_to(signin_path)
		end
		
		it "should deny access to 'edit'" do
			post :create
			response.should redirect_to(signin_path)
		end
	end

	describe "GET 'new'" do
		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
		end
	
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
		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
		end
		
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
				response.should render_template('new')
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
		before(:each) do
			@user = test_sign_in(Factory(:user))
			@company = Factory(:company)
		end
		
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
				it "should display a message saying no registered users exist" do
					get :show, :id => @company
					response.should have_selector("p", :content => "not have any users")
				end
				
				it "should display a message saying no unregistered users exist" do
					get :show, :id => @company
					response.should have_selector("p", :content => "no outstanding user invitations")
				end
			end
			
			describe "when they exist" do
				before(:each) do
					@other_user1 = Factory(:user, :email => "other_user1@testing.com", :name => "Other user1")
					@other_user2 = Factory(:user, :email => "other_user2@testing.com", :name => "Other user2")
					@other_user3 = Factory(:user, :email => "other_user3@testing.com", :name => "Other user3")
				
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
						response.should have_selector("li", :content => u.name)
					end
				end
			end
		end
	end
	
	describe "GET 'edit'" do
		before(:each) do
			@user = test_sign_in(Factory(:user))
			@company = Factory(:company)
		end
		
		it "should be successful" do
			get :edit, :id => @company
			response.should be_success
		end

		it "should have right title" do
			get :edit, :id => @company
			response.should have_selector("title", :content => "Company Settings")
		end
	end
	
	describe "GET 'index'" do
		before(:each) do
			@user = test_sign_in(Factory(:user))
			company1 = Factory(:company, :name => "Company1")
			company2 = Factory(:company, :name => "Company2")
			company3 = Factory(:company, :name => "Company3")
			@companies = [company1, company2, company3]
			
			30.times do
				@companies << Factory(:company, :name => Factory.next(:name))
			end
		end
		
		describe "as a non-admin user" do
			it "should protect the page" do
				get :index
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an admin user" do
			before(:each) do
				admin = Factory(:user, 
					:email => "admin@testing.com", 
					:admin => true)
				test_sign_in(admin)
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
	
	# describe "PUT 'update'" do
		# before(:each) do
			# @user = Factory(:user)
			# test_sign_in(@user)
		# end
		
		# describe "Failure" do
			# before(:each) do
				# @attr = {:name => "", 
				# :email => "", 
				# :password => "", 
				# :password_confirmation => ""}
			# end
			
			# it "should render the edit page" do
				# put :edit, :id => @user,  :user => @attr
				# response.should render_template('edit')
			# end
			
			# it "should have the right title" do
				# put :edit, :id => @user,  :user => @attr
				# response.should have_selector("title", :content => "Settings")
			# end
		# end
		
		# describe "Success" do
			# before(:each) do
				# @attr = {:name => "EditTest", 
				# :email => "edittest@testing.com", 
				# :password => "edittesting", 
				# :password_confirmation => "edittesting"}
			# end
			
			# it "Should change user successfully" do
				# put :update, :id => @user, :user => @attr
				# @user.reload
				# @user.name.should == @attr[:name]
				# @user.email.should == @attr[:email]
			# end
			
			# it "Should redirect to profile page" do
				# put :update, :id => @user, :user => @attr
				# response.should redirect_to(user_path(assigns(:user)))
			# end
			
			# it "Should have a success message" do
				# put :update, :id => @user, :user => @attr
				# flash[:success].should =~ /updated/i
			# end
		# end
	# end
	
	# describe "authentication of edit/update pages" do
		# before(:each) do
			# @user = Factory(:user)
		# end
		
		# describe "for non-signed-in users" do
			# it "should deny access to 'edit'" do
				# get :edit, :id => @user, :user => {}
				# response.should redirect_to(signin_path)
			# end
			
			# it "should deny access to 'update'" do
				# put :update, :id => @user, :user => {}
				# response.should redirect_to(signin_path)
			# end
		# end
		
		# describe "for signed-in users" do
			# before(:each) do
				# wrong_user = Factory(:user, :email => "wronguser@testing.com")
				# test_sign_in(wrong_user)
			# end
		
			# it "should require matching user to 'edit'" do
				# put :update, :id => @user, :user => {}
				# response.should redirect_to(root_path)
			# end
			
			# it "should require matching user to 'update'" do
				# put :update, :id => @user, :user => {}
				# response.should redirect_to(root_path)
			# end
		# end
	# end
	
	# describe "DELETE 'destroy'" do
		# before(:each) do
			# @user = Factory(:user)
		# end
		
		# describe "as a non-signed-in user" do
			# it "should redirect to root" do
				# delete :destroy, :id => @user
				# response.should redirect_to(signin_path)
			# end
		# end
		
		# describe "as a non-admin user" do
			# it "should protect the page" do
				# test_sign_in(@user)
				# delete :destroy, :id => @user
				# response.should redirect_to(root_path)
			# end
		# end
		
		# describe "as an admin user" do
			# before(:each) do
				# admin = Factory(:user, 
					# :email => "admin@testing.com", 
					# :admin => true)
				# test_sign_in(admin)
			# end
			
			# it "should destroy the user" do
				# lambda do
					# delete :destroy, :id => @user
				# end.should change(User, :count).by(-1)
			# end
			
			# it "should redirect to users page" do
				# delete :destroy, :id => @user
				# response.should redirect_to(users_path)
			# end
		# end
	# end
end
