class CreateAnswersTable < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :task_id
      t.string :content
      t.boolean :is_correct, :default => false
      t.integer :answer_count, :default => 0
      
      t.timestamps
    end
    
    add_column :completed_tasks, :answer_id, :integer
  end
end
