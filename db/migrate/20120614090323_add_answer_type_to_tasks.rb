class AddAnswerTypeToTasks < ActiveRecord::Migration
  #Task.all.each {|t| t.update_attribute(:answer_type, nil) }
  def change
    add_column :tasks, :answer_type, :integer, :default => 2
  end
end
