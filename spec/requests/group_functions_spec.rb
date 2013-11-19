require 'spec_helper'

describe "Group Functions" do
  before :each do
    init_metabright
  end
  
  it "should be able to create a Group without a Metabright account" do
    ActionMailer::Base.deliveries = nil
    visit root_path
    
    expect_content("Prove your skills.")
    click_button "Learn More"
    
    expect_content("What skills does your company need?")
    first("a[descriptor='signup-link']").trigger("click")
    
    expect_content("Begin Testing Your Candidates in Less Than 60 Seconds")
    click_on "premium subscriptions."
    
    expect_content("EVALUATOR PRICING")
    first("a[descriptor='six_to_fifteen']").trigger("click")
    
    expect_content("100% no-risk, free trial")
    find("#group_creator_name").set("Michael Jordan")
    find("#group_name").set("Chicago Bulls")
    find("#group_creator_email").set("mj1964@mailinator.com")
    find("#group_creator_password").set("projectmoonlite")
    find("#group_card_number").set("4242424242424242")
    find("#group_cvc_number").set("123")
    find("#group_card_month_expr").set("01")
    find("#group_card_year_expr").set("2018")
    click_on "Start My Free Trial"
    sleep(10)
    
    expect_content("Welcome to MetaBright!")
  end
  
  it "should be able to create a Group with a MetaBright account" do
    ActionMailer::Base.deliveries = nil
    @user = FactoryGirl.create(:user)
    sign_in(@user)
    
    visit evaluator_path
    
    expect_content("What skills does your company need?")
    first("a[descriptor='signup-link']").trigger("click")
    
    expect_content("Begin Testing Your Candidates in Less Than 60 Seconds")
    click_on "premium subscriptions."
    
    expect_content("EVALUATOR PRICING")
    first("a[descriptor='six_to_fifteen']").trigger("click")
    
    expect_content("100% no-risk, free trial")
    find("#group_name").set("Chicago Bulls")
    find("#group_card_number").set("4242424242424242")
    find("#group_cvc_number").set("123")
    find("#group_card_month_expr").set("01")
    find("#group_card_year_expr").set("2018")
    click_on "Start My Free Trial"
    sleep(10)
    
    expect_content("Welcome to MetaBright!")
    expect_content(@user.name)
  end

  it "should be able to create a trial group", js: true do
    visit trial_groups_path

    fill_in "group_name", with: "My Blog"
    fill_in "group_creator_name", with: "Blogger Man"
    fill_in "group_creator_email", with: "bloggerman@t.com"
    fill_in "group_creator_password", with: "a1b2c3d4"

    click_on "Create My Account"
    sleep(10)
    
    expect_content("Welcome to MetaBright!")
    group = Group.last
    expect_content(group.users.first.name)
  end
  
  describe "Challenge and Eval creation" do
    before :each do
      @group = FactoryGirl.create(:group)
    end
    
    it "should be able to create a Challenge" do
      @user = @group.users.first
      sign_in(@user)
      find("a[descriptor='challenges-index-link']").click
    
      click_on "Create a custom Challenge"
    
      fill_in 'path_name', with: "Hella Fly Challenge"
      find(".image_picker").first('img').click
      click_button "Create My Challenge"
    
      expect_content("Challenge questions")
      find("#task_question").set("This is a dummy question")
      find("#task_answer_new_1").set("This is the correct answer")
      find("#task_answer_new_2").set("This is the wrong answer")
      find("#task_answer_new_3").set("This is the wrong answer")
      find("#task_answer_new_4").set("This is the wrong answer")
      click_button "Add New Question"
    
      expect_content("Question added")
      find("a[descriptor='challenges-index-navbar-link']").click
      
      expect_content("Hella Fly Challenge")
    end
      
    it "should be able to create an Evaluation" do
      @user = @group.users.first
      sign_in(@user)
      @group_paths = FactoryGirl.create(:path_with_tasks, group_id: @group.id)
      find("a[descriptor='evaluations-index-link']").click
    
      expect_content("Create an Evaluation")
      click_on "Create an Evaluation"
    
      expect_content("New Evaluation")
      find("#evaluation_title").set("New Job")
      first(".metabright-challenges > li > label").click
      first(".custom-challenges > li > label").click
      click_on "Create Evaluation"
    
      expect_content("Your Evaluation has been created!")
      click_on "Continue to Evaluation Overview"
    
      expect_content("New Job")
    end
    
    it "should be able to submit an Evaluation", js: true do
      group_path = FactoryGirl.create(:path_with_tasks, group_id: @group.id)
      path = FactoryGirl.create(:path_with_tasks)
      selected_paths = {path.id => true, group_path.id => true}
      evaluation = FactoryGirl.create(:evaluation, selected_paths: selected_paths)
      consumer_user = FactoryGirl.create(:user)
      sign_in(consumer_user)
      
      visit take_group_evaluation_path(evaluation.permalink)
      
      expect_content evaluation.title
      select "Afghanistan", from: "user_country"
      select "Balkh", from: "user_state"
      find("#user_city").set("San Francisco")
      #find("input[descriptor=save-evaluation-button]").trigger("click")
      find("input[descriptor=save-evaluation-button]").click
      
      find(".challenge_holder").first('a').click
      
      12.times do |i|
        expect_content "#{i + 1} / 12"
        first('.answer_content').click
        click_on "Next"
        sleep 0.25
      end

      3.times do
        find("#answer_input").set("Blah")
        click_on "Submit"
        sleep 0.25
      end
      
      find(".challenge_holder").first('a').click
      
      12.times do |i|
        expect_content "#{i + 1} / 12"
        first('.answer_content').click
        click_on "Next"
        sleep 0.25
      end
      
      3.times do
        find("#answer_input").set("Blah")
        click_on "Submit"
        sleep 0.25
      end
      
      click_on "Submit"
      
      expect_content "Your application has been successfully submitted."
    end
    
    it "should give all admins edit access to custom Challenges" do
      @user = @group.users.first
      sign_in(@user)
      @group_paths = FactoryGirl.create(:path_with_tasks, group_id: @group.id, name: "Can U Get In?")
      @user2 = @group.users.last
      sign_in(@user2)
      
      find("a[descriptor='challenges-index-link']").click
      
      expect_content("Can U Get In?")
      find(".mosaic-block").first('a').click
      
      expect_content("Challenge questions")
    end
  end
end
      
      