require 'spec_helper'

describe "Group Functions" do
  describe "User" do
    # it "should be able to create a Group", js: true do
    #   visit root_path
    #   
    #   expect_content("Prove your skills.")
    #   click_button "Learn More"
    #   
    #   expect_content("What skills does your company need?")
    #   first('.submit_button').click
    #   
    #   expect_content("EVALUATOR PRICING")
    #   first('.action_button').click
    #   
    #   expect_content("100% no-risk, free trial")
    #   find("#group_creator_name").set("Michael Jordan")
    #   find("#group_name").set("Chicago Bulls")
    #   find("#group_creator_email").set("mj1964@mailinator.com")
    #   find("#group_creator_password").set("projectmoonlite")
    #   find("#group_card_number").set("4242424242424242")
    #   find("#group_cvc_number").set("123")
    #   find("#group_card_month_expr").set("01")
    #   find("#group_card_year_expr").set("2018")
    #   click_on "Start My Free Trial"
    #   sleep(10)
    #   
    #   expect_content("Welcome to MetaBright!")
    # end
    describe "Challenge and Eval creation" do
      before :each do
        init_metabright
        @group = FactoryGirl.create(:group)
      end
      
      # it "should be able to create a Challenge", js: true do
      #   @user = @group.users.first
      #   sign_in(@user)
      #   find(:css, "img[alt=Challenges]").click
      # 
      #   click_on "Create a custom Challenge"
      # 
      #   fill_in 'path_name', with: "Hella Fly Challenge"
      #   find(".image_picker").first('img').click
      #   click_button "Create My Challenge"
      # 
      #   expect_content("Challenge questions")
      #   find("#task_question").set("This is a dummy question")
      #   find("#task_answer_new_1").set("This is the correct answer")
      #   find("#task_answer_new_2").set("This is the wrong answer")
      #   find("#task_answer_new_3").set("This is the wrong answer")
      #   find("#task_answer_new_4").set("This is the wrong answer")
      #   click_button "Add New Question"
      # 
      #   expect_content("Question added")
      #   # something here to look at custom challenge page
      # end
      #     
      # it "should be able to create an Evaluation", js: true do
      #   @user = @group.users.first
      #   sign_in(@user)
      #   @group_paths = FactoryGirl.create(:path_with_tasks, group_id: @group.id)
      #   find(:css, "img[alt=Evaluations]").click
      # 
      #   expect_content("Create an Evaluation")
      #   click_on "Create an Evaluation"
      # 
      #   expect_content("New Evaluation")
      #   find("#evaluation_title").set("New Job")
      #   first(".metabright-challenges > li > label").click
      #   first(".custom-challenges > li > label").click
      #   click_on "Create Evaluation"
      # 
      #   expect_content("Your Evaluation has been created!")
      #   click_on "Continue to Evaluation Overview"
      # 
      #   expect_content("New Job")
      # end
      # 
      it "should be able to submit an Evaluation", js: true do
        group_path = FactoryGirl.create(:path_with_tasks, group_id: @group.id)
        selected_paths = {group_path.id => true}
        evaluation = FactoryGirl.create(:evaluation, selected_paths: selected_paths)
        consumer_user = FactoryGirl.create(:user)
        sign_in(consumer_user)
        
        visit take_group_evaluation_path(evaluation.permalink)
        
        expect_content evaluation.title
        select "Afghanistan", from: "user_country"
        select "Balkh", from: "user_state"
        find("#user_city").set("San Francisco")
        click_on "Save"
        
        find(".challenge_holder").first('a').click
        next_task1 = evaluation.next_task(consumer_user, group_path)[:next_task]
      
        expect_content next_task1.question
        sleep(5)
        first('.answer_content').click
        sleep(5)
        save_and_open_page
        click_on "Next"
        
        next_task2 = evaluation.next_task(consumer_user, group_path)
        raise "bad task" if next_task1 == next_task2
        
        expect_content next_task2.question
        first('.answer_content').click
        click_on "Next"
        
        next_task3 = evaluation.next_task(consumer_user, group_path)
        
        expect_content next_task3.question
        first('.answer_content').click
        click_on "Next"
        
        find("#answer_input").set("Blah")
        click_on "Submit"
        
        find("#answer_input").set("Blah")
        click_on "Submit"
        
        find("#answer_input").set("Blah")
        click_on "Submit"
        
        
        
      end
    end
  end
end
      
      