require 'spec_helper'

describe :Phrase do
	before(:each) do
		@attr = { :content => "Content" }
	end
	
	it "should create a new instance given valid attributes" do
		Phrase.create!(@attr)
	end
	
	describe "attributes" do
		it "should require non-blank content" do
			Phrase.new(:content => "").should_not be_valid
		end
				
		it "should reject long content" do
			Phrase.new(:name => "a"*256).should_not be_valid
		end
		
		it "should automatically downcase content" do
			Phrase.create(@attr).content.should == @attr[:content].downcase
		end
		
		it "should store original content in original content" do
			Phrase.create(@attr).original_content.should == @attr[:content]
		end
	end
end
