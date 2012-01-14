require 'spec_helper'

describe "Enrollments" do
	before(:each) do
		#Sign in
		@user = Factory(:user)
		@company = Factory(:company)
		Factory(:company_user, :user => @user, :company => @company)
		@path = Factory(:path, :user => @user, :company => @company)
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		visit paths_path
		click_link @path.name
	end
	
	describe 'creation' do
		describe "success" do
			it "should make a new enrollment" do
				lambda do
					click_button "Take Path"
					response.should render_template("paths/show")
					response.should have_selector("div.success")
				end.should change(Enrollment, :count).by(1)
			end

			# it "should make a new enrollment and not allow another" do
				# lambda do
					# click_button "Take Path"
					# click_button "Leave Path"
					# response.should have_selector("input#enrollment_submit", :value => "Take Path")
				# end.should_not change(Enrollment, :count)
			# end
		end
	end
end
