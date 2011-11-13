class ChangeRankToPoints < ActiveRecord::Migration
  def self.up
	rename_column :tasks, :rank, :points
  end

  def self.down
	rename_column :tasks, :points, :rank
  end
end
