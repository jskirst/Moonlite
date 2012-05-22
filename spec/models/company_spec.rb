require 'spec_helper'

describe "Company" do
  before(:each) do
    @attr = { 
      :name => "Example Company",
    }
  end
  
  it "should create a new instance given valid attributes" do
    Company.create!(@attr)
  end
  
  describe "validation" do
    it "should require a name" do
      Company.new(@attr.merge(:name => "")).should_not be_valid
    end
    
    it "should reject names that are too long" do
      Company.new(@attr.merge(:name => 'a' * 101)).should_not be_valid
    end
    
    it "should respond to enable_company_store" do
      c = Company.create!(@attr)
      c.should respond_to(:enable_company_store)
    end
    
    it "should set enable_company_store to false by default" do
      c = Company.create!(@attr)
      c.enable_company_store.should be_true
    end
  end
  
  describe "paths" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @path1 = FactoryGirl.create(:path, :user => @user, :company => @user.company)
      @path2 = FactoryGirl.create(:path, :user => @user, :company => @user.company)
    end
    
    it "should have a paths attribute" do
      @user.company.should respond_to(:paths)
    end
    
    it "should have the right paths" do
      @user.company.paths.to_a.include?(@path1).should == true
      @user.company.paths.to_a.include?(@path2).should == true
    end
    
    it "should destroy associated paths" do
      @user.company.destroy
      [@path1, @path2].each do |p|
        Path.find_by_id(p.id).should_not be_nil
      end
    end
  end
end
