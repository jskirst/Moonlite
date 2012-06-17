class AddTotalVotesAndTaskIdToSubmittedAnswers < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :total_votes, :integer, :default => 0
    add_column :submitted_answers, :task_id, :integer
    
    SubmittedAnswer.all.each do |sa|
      ct = CompletedTask.where("submitted_answer_id = ?", sa.id).first
      if ct
        sa.task_id = ct.task_id
        sa.save
      else
        sa.destroy
      end
    end    
  end
end
