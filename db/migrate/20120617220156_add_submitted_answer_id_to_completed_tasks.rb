class AddSubmittedAnswerIdToCompletedTasks < ActiveRecord::Migration
  def change
    add_column :completed_tasks, :submitted_answer_id, :integer
    
    SubmittedAnswer.all.each do |sa|
      ct = CompletedTask.find_by_id(sa.completed_task_id)
      if ct
        ct.submitted_answer_id = sa.id
        ct.save
      end
    end
    
    remove_column :submitted_answers, :completed_task_id
  end
end
