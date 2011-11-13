class ChangeAnswerColumnsToStrings < ActiveRecord::Migration
  def self.up
	change_column :tasks, :answer2, :string
	change_column :tasks, :answer3, :string
	change_column :tasks, :answer4, :string
  end

  def self.down
	change_column :tasks, :answer2, :integer
	change_column :tasks, :answer3, :integer
	change_column :tasks, :answer4, :integer
  end
end
