require 'spec_helper'

describe "Admin" do
  before :each do
    @user = init_metabright
    sign_in(@user)
  end
  
  it "should load all tabss successfully" do
    visit admin_overview_path
    expect_content("All Time")
    
    visit admin_funnel_path
    expect_content("Last 7 days")
    
    visit admin_visits_path
    expect_content("Referrer")
    
    visit personas_path
    expect_content("Name")
    
    visit admin_paths_path
    expect_content("Published")
    
    visit admin_users_path
    expect_content("Created")
    
    visit admin_submissions_path
    expect_content("Approve")
    
    visit admin_tasks_path
    expect_content("Question")
    
    visit admin_comments_path
    expect_content("Path/Idea")
    
    visit admin_groups_path
    expect_content("Challenges")
    
    visit admin_email_path
    expect_content("Preview")
  end
end