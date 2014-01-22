require "spec_helper"

describe CustomStyle do
  before :each do
    @user = FactoryGirl.create(:user)
  end
  
  describe ".validate_css" do
    it "should not allow valid css" do
      style = CustomStyle.new(styles: "ASDF", mode: CustomStyle::ON)
      style.owner = @user
      style.save

      style.reload
      style.mode.should == CustomStyle::OFF
      style.css_validation_errors.should_not be_empty
      style.styles.should == "ASDF"
    end
    
    it "should allow valid css" do
      style = CustomStyle.new(styles: "body { padding: 10px; }", mode: CustomStyle::ON)
      style.owner = @user
      style.should be_valid
    end
  end
  
  describe "self.validate_all_styles" do
    before :each do
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
    
    it "should not touch valid styles" do
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