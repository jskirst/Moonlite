require "spec_helper"

describe UserEvent do
  describe "user_event_icon method" do
    it "should return image url" do
      UserEvent.user_event_icon(:hall_of_fame).should == "https://s3.amazonaws.com/moonlite-nsdub/static/Event+Icons/event_icon_achievement.png"
    end
  end
end