class AddTimingDetailsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :disable_time_limit, :boolean, :default => false
    add_column :tasks, :time_limit, :integer, :default => 30 
  end
end
