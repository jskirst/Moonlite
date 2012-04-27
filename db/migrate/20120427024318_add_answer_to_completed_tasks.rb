class AddAnswerToCompletedTasks < ActiveRecord::Migration
  def change
		add_column :completed_tasks, :answer, :string
  end
end
