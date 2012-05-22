require 'spec_helper'

describe :Category do
  before(:each) do
    @company = FactoryGirl.create(:company)
    @attr = { :name => "Test name" }
  end
  
  it "should create a new instance given valid attributes" do
    @company.categories.create!(@attr)
  end
  
  describe "attributes" do
    it "should require a company id" do
      Category.new(@attr).should_not be_valid
    end
    
    it "should require non-blank name" do
      @company.categories.build(:name => "").should_not be_valid
    end

    it "should reject long name" do
      @company.categories.build(:name => "a"*81).should_not be_valid
    end
  end
  
  describe "company association" do
    before(:each) do
      @category = @company.categories.build(@attr)
    end
    
    it "should have a company attribute" do
      @category.should respond_to(:company)
    end
    
    it "should require a company" do
      @category.company = nil
      @category.should_not be_valid
    end
  end
  
  describe "paths associations" do
    before(:each) do
      @category = @company.categories.create!(@attr)
      @path1 = FactoryGirl.create(:path, :category => @category)
      @path2 = FactoryGirl.create(:path, :category => @category)
      @category.reload
    end
    
    it "should have a sections attribute" do
      @category.should respond_to(:paths)
    end
    
    it "should return the right sections in the right order (lowest position first)" do
      @category.paths.should == [@path1, @path2]
    end
    
    it "should prevent distruction until paths were removed" do
      @category.paths.should == [@path1, @path2]
      @category.destroy.should be_false
    end
    
    it "should prevent distruction until paths were removed" do
      @path1.destroy
      @path2.destroy
      @category.destroy.should be_true
    end
  end
end
