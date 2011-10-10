class RenameModules < ActiveRecord::Migration
  def self.up
	rename_table :modules, :paths
  end

  def self.down
	rename_table :paths, :modules
  end
end
