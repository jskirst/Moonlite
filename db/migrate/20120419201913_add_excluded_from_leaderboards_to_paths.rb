class AddExcludedFromLeaderboardsToPaths < ActiveRecord::Migration
  def change
		add_column :paths, :excluded_from_leaderboards, :string
  end
end
