require 'spec_helper'

describe PathsController do
	render_views
	
	before(:each) do
		@company = FactoryGirl.create(:company)
		@regular_user_roll = FactoryGirl.create(:user_roll, :company => @company, :enable_administration => "f", :enable_user_creation => "f", :enable_collaboration => "f")
		@admin_user_roll = FactoryGirl.create(:user_roll, :company => @company)
		@user = FactoryGirl.create(:user, :company => @company, :user_roll => @regular_user_roll)
		
		@category = FactoryGirl.create(:category, :company => @company)
		@path = FactoryGirl.create(:path, :user => @user, :company => @user.company, :category => @categoy)
		@section = FactoryGirl.create(:section, :path => @path)
		@task = FactoryGirl.create(:task, :section => @section)
		
		@other_user = FactoryGirl.create(:user)
		
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
			it "should deny access to all functionality" do
				get :new
				response.should redirect_to signin_path
				post :create, :path => @path
				response.should redirect_to signin_path
				get :edit, :id => @path.id
				response.should redirect_to signin_path
				delete :destroy, :id => @path.id
				response.should redirect_to signin_path
			end
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user)
			end
			
			it "should deny access to all editing functionality" do
				get :new
				response.should redirect_to root_path
				post :create, :path => @attr
				response.should redirect_to root_path
				get :edit, :id => @path
				response.should redirect_to root_path
				delete :destroy, :id => @path
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@user.user_roll = @admin_user_roll
				test_sign_in(@user)
			end
			
			it "should allow access to all functionality" do
				get :new
				response.should be_success
				post :create, :path => @attr
				response.should redirect_to edit_path_path(Path.last, :m => "start")
				get :edit, :id => @path
				response.should be_success
				delete :destroy, :id => @path
				response.should redirect_to root_path
			end
		end
	end
	
	describe "actions" do
		before(:each) do
			@user.user_roll = @admin_user_roll
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
					response.should redirect_to edit_path_path(Path.last, :m => "start")
				end
				
				it "should have a flash message" do
					post :create, :path => @attr
					flash[:success].should =~ /challenge created/i
				end			
				
				it "should return path pic set in image_url" do
					@attr = @attr.merge(:name => "Image url test")
					post :create, :path => @attr
					Path.find_by_name(@attr[:name]).path_pic.should == @attr[:image_url]
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
					response.should redirect_to edit_path_path(@path)
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
      it "should not show any unpublished paths" do
				@user.set_company_admin(false)
				unpublished_path = FactoryGirl.create(:path, :company => @user.company, :user => @user, :is_published => false)
				get :show, :id => unpublished_path
				response.should redirect_to root_path
			end
      
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
				response.should have_selector("div", :content => @path.description)
			end
			
			it "should show all the published sections" do
				@sections = []
				3.times do 
					@sections << FactoryGirl.create(:section, :path => @path, :is_published => true)
				end
				get :show, :id => @path
				@sections.each do |s| 
					response.should have_selector("img", :title => s.name)
				end
			end
      
      it "should not show any unpublished sections" do
				@section.is_published = false
				@section.save
				@path.reload
				get :show, :id => @path
				response.should_not have_selector("a", :content => @section.name)
			end
		end
		
	end
end
	