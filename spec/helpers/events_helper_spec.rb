require 'spec_helper'

describe EventsHelper do
  before :each do
    @path = FactoryGirl.create(:path)
    @user = FactoryGirl.create(:user)
    @enrollment = FactoryGirl.create(:enrollment, user: @user, path: @path)
  end

  describe ".check_achievements(new_points, enrollment)" do
    it "should detect a level increase" do
      achievements = helper.check_achievements(1000, @enrollment)
      achievements[:level].should_not be_nil
    end

    it "should detect a rank increase" do
      6.times{ FactoryGirl.create(:enrollment, path: @path, total_points: 2000) }
      6.times{ FactoryGirl.create(:enrollment, path: @path, total_points: 1000) }

      @enrollment.update_attribute(:total_points, 1200)
      achievements = helper.check_achievements(300, @enrollment)
      achievements[:rank].should_not be_nil
    end

    it "should detect if you cross the contribution thresold" do
      @enrollment.update_attribute(:total_points, 1800)
      achievements = helper.check_achievements(800, @enrollment)
      achievements[:contribution].should_not be_nil
    end
  end

  describe ".check_for_and_create_events(new_points, enrollment)" do
    it "should create an event if there is a rank increase" do
      6.times{ FactoryGirl.create(:enrollment, path: @path, total_points: 2000) }
      6.times{ FactoryGirl.create(:enrollment, path: @path, total_points: 1000) }

      @enrollment.update_attribute(:total_points, 1200)
      events = check_for_and_create_events(800, @enrollment)
      events.size.should == 1
      event = events[0]
      event.content.should == "#{@enrollment.user.name} just broke into the Top 10 on the #{@enrollment.path.name} Challenge Leaderboard."
    end
  end
end