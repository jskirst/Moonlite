class CleanUpCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :enable_company_store
    remove_column :companies, :enable_leaderboard
    remove_column :companies, :enable_dashboard
    remove_column :companies, :enable_tour
    remove_column :companies, :enable_comments
    remove_column :companies, :enable_feedback
    remove_column :companies, :enable_achievements
    remove_column :companies, :enable_recommendations
    remove_column :companies, :enable_printer_friendly
    remove_column :companies, :enable_browsing
    remove_column :companies, :enable_user_creation
    remove_column :companies, :enable_collaboration
    remove_column :companies, :enable_one_signup
    remove_column :companies, :enable_auto_generate
    remove_column :companies, :signup_token
    add_column :companies, :enable_traditional_explore, :boolean, default: true
    add_column :companies, :home_title, :string
    add_column :companies, :home_subtitle, :string
    add_column :companies, :home_paragraph, :string
    add_column :companies, :big_logo_link, :string
    add_column :companies, :small_logo_link, :string
    add_column :companies, :referrer_url, :string
    add_column :companies, :enable_custom_landing, :boolean, default: false
  end
end
