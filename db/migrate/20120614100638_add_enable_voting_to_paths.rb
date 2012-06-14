class AddEnableVotingToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :enable_voting, :boolean, :default => false
  end
end
