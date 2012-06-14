class CreateSubmittedAnswersTable < ActiveRecord::Migration
  def change
    create_table :submitted_answers do |t|
      t.integer :completed_task_id
      t.string :content
      
      t.timestamps
    end
  end
end
