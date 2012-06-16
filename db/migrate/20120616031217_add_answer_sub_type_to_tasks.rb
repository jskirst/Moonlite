class AddAnswerSubTypeToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :answer_sub_type, :integer
  end
end
