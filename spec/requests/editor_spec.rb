require 'spec_helper'

describe "Editor" do
  before :each do
    @user = init_metabright
    sign_in(@user)
    @user.paths.size.should eq(1)
    @path = @user.paths.first
  end
  
  describe "index" do
    it "should show all created paths" do
      click_on "Create"
      expect_content(@path.name)
    end
  end
  
  describe "editor" do
    it "should show all tasks" do
      visit edit_path_path(@path)
      @path.tasks.size.should_not eq(0)
      @path.tasks.each do |t|
        expect_content(t.question)
      end
    end
  end
end
      
