# require 'spec_helper'

# describe CommentsController do
  # render_views
  
  # before(:each) do
    # @user = FactoryGirl.create(:user)
    # @path = FactoryGirl.create(:path, :user => @user, :company => @user.company)
    # @section = FactoryGirl.create(:section, :path => @path)
    # @task = FactoryGirl.create(:task, :section => @section)
    # @user.enroll!(@path)
    
    # @comment = FactoryGirl.create(:comment, :task => @task, :user => @user)
    # @attr = { :task_id => @task, :content => "Comment content" }
  # end
  
  # describe "access controller" do
		# describe "when not signed in" do
			# it "should deny access to 'create'" do
				# post :create, :comment => @attr
				# response.should redirect_to signin_path
			# end

			# it "should deny access to 'destroy'" do
				# delete :destroy, :id => @comment
				# response.should redirect_to signin_path
			# end				
		# end
    
    # describe "when signed in as an unenrolled user" do
			# before(:each) do
        # @other_user = FactoryGirl.create(:user, :company => @user.company)
				# test_sign_in(@other_user)
			# end
			
			# it "should deny access to 'create'" do
				# post :create, :comment => @attr
				# response.should redirect_to root_path
			# end
      
			# it "should deny access to 'destroy'" do
				# delete :destroy, :id => @comment
				# response.should redirect_to root_path
			# end	
		# end
		
		# describe "when signed in as a user" do
			# before(:each) do
				# test_sign_in(@user)
			# end
			
			# it "should allow access to 'create'" do
				# post :create, :comment => @attr
				# response.should redirect_to @task
			# end
      
			# it "should allow access to 'destroy' if user created comment" do
				# delete :destroy, :id => @comment
				# response.should redirect_to @task
			# end
      
      # it "should deny access to 'destroy' if user did not create comment" do
				# @other_company_user = FactoryGirl.create(:user, :company => @user.company)
        # @other_company_user.enroll!(@path)
        # @other_comment = FactoryGirl.create(:comment, :task => @task, :user => @other_company_user)
        # delete :destroy, :id => @other_comment
				# response.should redirect_to root_path
			# end
		# end
  # end

  # describe "POST create" do
    # before(:each) do
      # test_sign_in(@user)
    # end
    
    # describe "with valid params" do
      # it "should create a new Comment" do
        # lambda do
          # post :create, :comment => @attr        
        # end.should change(Comment, :count).by(1)
      # end

      # it "should redirect to the task" do
        # post :create, :comment => @attr
        # response.should redirect_to @task
      # end
    # end

    # describe "with invalid params" do
      # it "should redirect back to task" do
        # post :create, :comment => {}
        # response.should redirect_to root_path
      # end

      # it "should not create a new Comment" do
        # lambda do
          # post :create, :comment => {}    
        # end.should_not change(Comment, :count)
      # end
    # end
  # end

  # describe "DELETE destroy" do
    # before(:each) do
      # test_sign_in(@user)
    # end
    
    # it "should destroy the comment" do
      # lambda do
        # delete :destroy, :id => @comment.id
      # end.should change(Comment, :count).by(-1)
    # end

    # it "redirects to the task" do
      # delete :destroy, :id => @comment.id
      # response.should redirect_to @task
    # end
  # end
# end
