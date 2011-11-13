class AddQuizSessionToCompletedTask < ActiveRecord::Migration
  def self.up
	add_column :completed_tasks, :quiz_session, :datetime
  end

  def self.down
	remove_column :completed_tasks, :quiz_session
  end
end
