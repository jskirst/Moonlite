class AddCategorySectionAndPathToLeaderboard < ActiveRecord::Migration
  def change
		add_column :leaderboards, :category_id, :integer
		add_column :leaderboards, :path_id, :integer
		add_column :leaderboards, :section_id, :integer
  end
end
