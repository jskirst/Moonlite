class AddIndexOnSubmittedAnswersToCompletedTasks < ActiveRecord::Migration
  def change
    add_index :completed_tasks, [:submitted_answer_id]
  end
end
