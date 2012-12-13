class CleanUpCompletedTask < ActiveRecord::Migration
  def change
    remove_column :completed_tasks, :quiz_session
    add_column    :completed_tasks, :is_private, :boolean, default: false
    add_column    :completed_tasks, :is_restricted, :boolean, default: false
    
    drop_table    :company_users
    
    remove_column :enrollments, :is_complete
    remove_column :enrollments, :level
    remove_column :enrollments, :is_score_sent
    remove_column :enrollments, :is_passed
    remove_column :enrollments, :percentage_correct
    
    drop_table    :leaderboards
    
    drop_table    :path_user_roles
    
    remove_column :paths, :purchased_path_id
    remove_column :paths, :enable_section_display
    remove_column :paths, :default_timer
    remove_column :paths, :enable_nonlinear_sections
    remove_column :paths, :enable_retakes
    remove_column :paths, :passing_score
    remove_column :paths, :enable_path_retakes
    
    remove_column :personas, :criteria
    
    drop_table    :rewards
    
    remove_column :sections, :image_url
    remove_column :sections, :content_type
    remove_column :sections, :hidden_content
    remove_column :sections, :enable_skip_content
    
    remove_column :tasks, :answer1
    remove_column :tasks, :answer2
    remove_column :tasks, :answer3
    remove_column :tasks, :answer4
    
    drop_table    :usage_reports
    
    remove_column :user_roles, :enable_leaderboard
    remove_column :user_roles, :enable_dashboard
    remove_column :user_roles, :enable_tour
    remove_column :user_roles, :enable_rewards
    remove_column :user_roles, :enable_comments
    remove_column :user_roles, :enable_feedback
    remove_column :user_roles, :enable_news
    remove_column :user_roles, :enable_achievements
    remove_column :user_roles, :enable_recommendations
    remove_column :user_roles, :enable_printer_friendly
    remove_column :user_roles, :enable_browsing
    remove_column :user_roles, :enable_auto_enroll
    remove_column :user_roles, :enable_collaboration
    remove_column :user_roles, :enable_one_signup
    remove_column :user_roles, :enable_company_store
    remove_column :user_roles, :enable_auto_generate
    
    rename_column :user_roles, :enable_user_creation, :enable_content_creation

    remove_column :users, :provider
    remove_column :users, :uid
    remove_column :users, :company_admin
    remove_column :users, :is_anonymous
  end
end
