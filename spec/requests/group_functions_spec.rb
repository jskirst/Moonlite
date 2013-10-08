require 'spec_helper'

describe "Group Functions" do
  describe "User" do
    it "should be able to create a Group", js: true do
      visit root_path
      
      expect_content("Prove your skills.")
      click_button "Learn More"
      
      expect_content("What skills does your company need?")
      first('.submit_button').click
      
      expect_content("EVALUATOR PRICING")
      first('.action_button').click
      
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
  end
end
      
      