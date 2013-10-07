require "spec_helper"

describe CustomStyle do
  before :all do
    @user = FactoryGirl.create(:user)
  end
  
  describe ".validate_css" do
    it "should not allow valid css" do
      style = CustomStyle.new(styles: "ASDF", mode: CustomStyle::ON)
      style.owner = @user
      style.should_not be_valid
    end
    
    it "should allow valid css" do
      style = CustomStyle.new(styles: "body { padding: 10px; }", mode: CustomStyle::ON)
      style.owner = @user
      style.should be_valid
    end
    
    it "should only test if css is in preview or on mode" do
      style = CustomStyle.new(styles: "ASDF")
      style.owner = @user
      
      style.mode = CustomStyle::ON
      style.should_not be_valid
      
      style.mode = CustomStyle::PREVIEW
      style.should_not be_valid
      
      style.mode = CustomStyle::OFF
      style.should be_valid
    end
  end
  
  describe "self.validate_all_styles" do
    before :all do
      @user2 = FactoryGirl.create(:user)
      @user3 = FactoryGirl.create(:user)
    end
    
    it "should turn off all invalid styles" do
      cs1 = CustomStyle.new(styles: "ASDF", mode: CustomStyle::ON)
      cs1.owner = @user
      cs1.save(validate: false)
      
      cs2 = CustomStyle.new(styles: "ASDF", mode: CustomStyle::PREVIEW)
      cs2.owner = @user2
      cs2.save(validate: false)
      
      CustomStyle.validate_all_styles
      cs1.reload
      cs1.mode.should eq(CustomStyle::OFF)
      cs2.reload
      cs2.mode.should eq(CustomStyle::OFF)
    end
    
    it "should leave not touch valid styles" do
      cs1 = CustomStyle.new(styles: "body { padding: 10px; }", mode: CustomStyle::ON)
      cs1.owner = @user
      cs1.save!
      
      cs2 = CustomStyle.new(styles: "body { padding: 10px; }", mode: CustomStyle::PREVIEW)
      cs2.owner = @user2
      cs2.save!
      
      cs3 = CustomStyle.new(styles: "body { padding: 10px; }", mode: CustomStyle::OFF)
      cs3.owner = @user3
      cs3.save!
      
      CustomStyle.validate_all_styles
      cs1.reload
      cs1.mode.should eq(CustomStyle::ON)
      cs2.reload
      cs2.mode.should eq(CustomStyle::PREVIEW)
      cs3.reload
      cs3.mode.should eq(CustomStyle::OFF)
    end
  end
end