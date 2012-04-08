class AddEnableDashboardAndLeaderboardAndTourToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :enable_leaderboard, :boolean, :default => true
    add_column :companies, :enable_dashboard, :boolean, :default => true
    add_column :companies, :enable_tour, :boolean, :default => true
  end
end
