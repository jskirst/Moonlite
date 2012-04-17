class AddFacebookAchievementsRecommendationsNewsPrinterEnabledToCompany < ActiveRecord::Migration
  def change
		add_column :companies, :enable_comments, :boolean, :default => true
		add_column :companies, :enable_feedback, :boolean, :default => true
		add_column :companies, :enable_news, :boolean, :default => true
		add_column :companies, :enable_achievements, :boolean, :default => true
		add_column :companies, :enable_recommendations, :boolean, :default => true
		add_column :companies, :enable_printer_friendly, :boolean, :default => true
		add_column :companies, :enable_browsing, :boolean, :default => true
		add_column :companies, :enable_user_creation, :boolean, :default => true
  end
end
