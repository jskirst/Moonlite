require 'spec_helper'

describe PathsController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user, :company => @user.company)
		
		@attr = {
			:name => "Path name", 
			:description => "Path description",
			:image_url => "http://placehold.it/210x150",
			:company_id => @user.company.id,
			:user_id => @user.id
		}
	end
	
	describe "access controller" do
		describe "when not signed in" do
			it "should deny access to 'new'" do
				get :new
				response.should redirect_to signin_path
			end
		
			it "should deny access to 'create'" do
				post :create, :path => @path
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @path.id
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'delete'" do
				delete :destroy, :id => @path.id
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'file'" do
				get :file, :id => @path
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'upload'" do
				post :upload, :id => @path
				response.should redirect_to signin_path
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
				post :create, :path => @attr
				response.should redirect_to root_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @path
				response.should redirect_to root_path
			end
			
			it "should deny access to 'delete'" do
				delete :destroy, :id => @path
				response.should redirect_to root_path
			end
			
			it "should deny access to 'file'" do
				get :file, :id => 1
				response.should redirect_to root_path
			end
			
			it "should deny access to 'upload'" do
				post :upload, :id => 1
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@user.company_user.toggle!(:is_admin)
				test_sign_in(@user)
			end
			
			it "should allow access to 'new'" do
				get :new
				response.should be_success
			end
		
			it "should allow access to 'create'" do
				post :create, :path => @attr
				response.should redirect_to Path.find(2)
			end
			
			it "should allow access to 'edit'" do
				get :edit, :id => @path
				response.should be_success
			end
			
			it "should allow access to 'delete'" do
				delete :destroy, :id => @path
				response.should redirect_to paths_path
			end
			
			it "should allow access to 'file'" do
				get :file, :id => @path
				response.should be_success
			end
			
			it "should allow access to 'upload'"
		end
	end
	
	describe "actions" do
		before(:each) do
			@user.company_user.toggle!(:is_admin)
			test_sign_in(@user)
		end
		
		describe "GET 'new'" do
			it "should have right title" do
				get :new
				response.should have_selector("title", :content => "New Path")
			end
		end
		
		describe "GET 'edit'" do
			it "should be successful" do
				get :edit, :id => @path
				response.should be_success
			end

			it "should have right title" do
				get :edit, :id => @path
				response.should have_selector("title", :content => "Edit")
			end
		end
		
		describe "POST 'create'" do
			describe "failure" do
				describe "with empty values" do
					before(:each) do
						@attr = @attr.merge(:name => "", :description => "")
					end
				
					it "should not create a path" do
						lambda do
							post :create, :path => @attr  
						end.should_not change(Path, :count)
					end
					
					it "should send you back to the new page" do
						post :create, :path => @attr
						response.should render_template("paths/new")
					end
					
					it "should display an error message" do
						post :create, :path => @attr
						response.should have_selector("div#error_explanation")
					end
				end
			end
			
			describe "success" do
				it "should create a path" do
					lambda do
						post :create, :path => @attr
					end.should change(Path, :count).by(1)		
				end
				
				it "should redirect to the path page" do
					post :create, :path => @attr
					response.should redirect_to Path.find(2)
				end
				
				it "should have a flash message" do
					post :create, :path => @attr
					flash[:success].should =~ /path created/i
				end			
				
				it "should return path pic set in image_url" do
					post :create, :path => @attr
					Path.find(2).path_pic.should == @attr[:image_url]
				end
			end
		end
		
		describe "PUT 'update'" do
			before(:each) do
				@attr = @attr.merge( :name => "New Path Name", :image_url => "http://changedimage.com" )
			end
				
			describe "failure" do
				describe "with empty values" do
					before(:each) do
						@attr = @attr.merge(:name => "", 
							:description => "",
							:image_url => "")
					end
				
					it "should not create a path" do
						lambda do
							put :update, :id => @path, :path => @attr  
						end.should_not change(Path, :count)
					end
					
					it "should send you back to the edit page" do
						put :update, :id => @path, :path => @attr  
						response.should render_template("paths/edit")
					end
					
					it "should have an error message" do
						put :update, :id => @path, :path => @attr
						response.should have_selector("div#error_explanation")
					end
				end
			end
			
			describe "success" do
				it "should change a path" do
					lambda do
						put :update, :id => @path, :path => @attr
						@path.reload
					end.should change(@path, :name).to(@attr[:name])	
				end
				
				it "should redirect to the path page" do
					put :update, :id => @path, :path => @attr
					response.should redirect_to @path
				end
				
				it "should have a flash message" do
					put :update, :id => @path, :path => @attr
					flash[:success].should =~ /changes saved/i
				end
				
				it "should return profile pic set in image_url" do
					put :update, :id => @path, :path => @attr
					@path.reload
					@path.path_pic.should == @attr[:image_url]
				end
			end
		end
		
		describe "DELETE 'destroy'" do
			it "should destroy the path" do
				lambda do
					delete :destroy, :id => @path
				end.should change(Path, :count).by(-1)
			end
		end
		
		describe "GET 'show'" do
			it "should find the right path" do
				get :show, :id => @path
				assigns(:path).should == @path
			end
			
			it "should have the path's name in the title" do
				get :show, :id => @path
				response.should have_selector("title", :content => @path.name)
			end
			
			it "should have the path's name in the header" do
				get :show, :id => @path
				response.should have_selector("h1", :content => @path.name)
			end
			
			it "should have the path's description" do
				get :show, :id => @path
				response.should have_selector("p", :content => @path.description)
			end
			
			it "should show all the resources for the path" do	
				@resources = []
				3.times do
					@resources << Factory(:resources, :path => @path)
				end
				get :show, :id => @path
				@resources.each do |r|
					response.should have_selector("p", :content => r.description)
				end
			end
			
			it "should show all the achievements possible for the path" do
				@achievements = []
				3.times do 
					@achievements << Factory(:achievements, :path => @path)
				end
				get :show, :id => @path
				@achievements.each do |s|
					response.should have_selector("a", :content => a.name)
				end
			end
			
			it "should show all the sections for a path" do
				@sections = []
				3.times do 
					@sections << Factory(:section, :path => @path)
				end
				get :show, :id => @path
				@sections.each do |s| 
					response.should have_selector("a", :content => s.name)
				end
			end
		end

		describe "GET 'file'" do
			before(:each) do
				@path = Factory(:path, :user => @user)
				@other_user = Factory(:user, :email => "other@t.com")
			end
			
			it "should be successful" do
				test_sign_in(@user)
				get :file, :id => @path
				response.should be_success
			end
			
			it "should have right title" do
				test_sign_in(@user)
				get :file, :id => @path
				response.should have_selector("title", :content => "File")
			end
		end
		
		describe "POST 'upload'" do
			before(:each) do
				@path = Factory(:path, :user => @user)
				test_sign_in(@user)
			end
			
			describe "failure" do
				before(:each) do
					@attr = { 
					:file => nil }
				end
			
				it "should not add questions to a path" do
					lambda do
						post :upload, :id => @path.id, :path => @attr
					end.should change(Task, :count).by(0)	
				end
				
				it "should render the file page" do
					post :upload, :id => @path.id, :path => @attr
					response.should render_template("file")
				end
			end
		end
		
		describe "GET 'marketplace'" do
			before(:each) do
				@other_user = Factory(:user)
				
				@purchaseable_paths = []
				3.times do
					@purchaseable_paths << Factory(:path, :company => @other_user.company, :user => @other_user, :is_public => true)
				end
			end

			describe "without search terms" do
				it "should be successful" do
					get :marketplace
					response.should be_success
				end
			end
			
			describe "with search terms" do
				describe "that do not have results" do
					it "should be successful" do
						get :marketplace, :search => "ABCDEFGHIJK123"
						response.should be_success
					end
					
					it "should state that there are no results" do
						get :marketplace, :search => "ABCDEFGHIJK123"
						response.should have_selector("p", :content => "returned 0 results.")
					end
				end
				
				describe "that do have results" do
					it "should be successful" do
						get :marketplace, :search => "Ruby"
						response.should be_success
					end
					
					it "should have right header" do
						get :marketplace, :search => "Ruby"
						response.should have_selector("h1", :content => "Path Marketplace")
					end
					
					it "should have listings for each result by name" do
						get :marketplace, :search => "Ruby"
						@purchaseable_paths.each do |p|
							response.should have_selector("span", :content => p.name)
						end
					end
				end
			end
		end
		
		describe "GET 'review'" do
			before(:each) do
				@other_user = Factory(:user)
				@purchaseable_path = Factory(:path, :company => @other_user.company, :user => @other_user, :is_public => true)
			end
			
			describe "failure" do				
				it "should redirect bad path id to root_path" do
					get :review, :id => "abc"
					response.should redirect_to root_path
				end
				
				it "should redirect private path request to root_path" do
					unpurchaseable_path = Factory(:path, :company => @other_company, :user => @other_user, :is_public => false)
					get :review, :id => unpurchaseable_path
					response.should redirect_to root_path
				end
			end
		
			describe "success" do
				it "should be successful" do
					get :review, :id => @purchaseable_path
					response.should be_success
				end

				it "should have right title" do
					get :review, :id => @purchaseable_path
					response.should have_selector("title", :content => "Review purchase")
				end
				
				it "should have the right name" do
					get :review, :id => @purchaseable_path
					response.should have_selector("h2", :content => @purchaseable_path.name)
				end
			end
		end
		
		describe "GET 'purchase'" do
			before(:each) do
				@other_user = Factory(:user, :email => "path_author@testing.com")
				@purchaseable_path = Factory(:path, :company => @other_user.company, :user => @other_user, :is_public => true)
			end
			
			describe "failure" do				
				it "should redirect bad path id to root_path" do
					get :purchase, :id => "abc"
					response.should redirect_to root_path
				end
				
				it "should redirect private path request to root_path" do
					unpurchaseable_path = Factory(:path, :company => @other_company, :user => @other_user, :is_public => false)
					get :purchase, :id => unpurchaseable_path
					response.should redirect_to root_path
				end
			end
			
			describe "success" do
				it "should display success message" do
					get :purchase, :id => @purchaseable_path
					flash[:success].should =~ /purchase successful/i
				end

				it "should have right title" do
					get :purchase, :id => @purchaseable_path
					response.should have_selector("title", :content => "Purchase successful")
				end
				
				it "should have the right path name" do
					get :purchase, :id => @purchaseable_path
					response.should have_selector("h2", :content => @purchaseable_path.name)
				end
				
				it "should create a new path" do
					lambda do
						get :purchase, :id => @purchaseable_path
					end.should change(Path, :count).by(1)
				end
				
				it "should set the purchased path for the new path" do
					get :purchase, :id => @purchaseable_path
					purchased_path = Path.find(:first, :conditions => ["company_id = ? and purchased_path_id = ?", @user.company.id, @purchaseable_path.id])
					purchased_path.name.should == @purchaseable_path.name
				end
				
				it "should create a new transaction" do
					lambda do
						get :purchase, :id => @purchaseable_path
					end.should change(UserTransaction, :count).by(1)
				end
				
				it "should have point transaction with correct path" do
					get :purchase, :id => @purchaseable_path
					ut = UserTransaction.find(:first, :conditions => ["path_id = ? and user_id = ?", @purchaseable_path.id, @user.id])
					ut.path_id.should == @purchaseable_path.id
					ut.path.should == @purchaseable_path
				end
				
				it "should have point transaction with the correct points" do
					get :purchase, :id => @purchaseable_path
					ut = UserTransaction.find(:first, :conditions => ["path_id = ? and user_id = ?", @purchaseable_path.id, @user.id])
					ut.amount.should == 15.00
				end
				
				it "should create and associate all the sections and tasks for the purchased path" do
					@tasks = []
					@sections = []
					3.times do
						section = Factory(:section, :path => @purchaseable_path)
						@sections << section
						3.times do
							@tasks << Factory(:task, :section => section)
						end
					end
					
					get :purchase, :id => @purchaseable_path
					purchased_path = Path.find(:first, :conditions => ["company_id = ? and purchased_path_id = ?", @user.company.id, @purchaseable_path.id])
					3.times do |n|
						purchased_section = purchased_path.sections[n]
						purchased_section.name.should == @sections[n].name
						3.times do |n|
							purchased_section.tasks[n].question.should == @tasks[n].question
						end
					end
				end
			end
		end
	end
end
	