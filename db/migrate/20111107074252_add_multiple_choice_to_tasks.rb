class AddMultipleChoiceToTasks < ActiveRecord::Migration
	def self.up
		rename_column :tasks, :answer, :answer1
		add_column :tasks, :answer2, :integer
		add_column :tasks, :answer3, :integer 
		add_column :tasks, :answer4, :integer
		add_column :tasks, :correct_answer, :integer, :default => 1
	end

	def self.down
		rename_column :tasks, :answer1, :answer
		remove_column :tasks, :answer2
		remove_column :tasks, :answer3
		remove_column :tasks, :answer4
		remove_column :tasks, :correct_answer
	end
end